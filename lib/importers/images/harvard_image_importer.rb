# Collection
# Fascicle
# Work Images
# Sheets
# Don't forget positions
#
# For each page, one image gets created, then assigned to various image groups:
#   The group for the collection
#   The group for a sheet
#   The group for each work
#
#
# What does the hierarchy look like for image groups?
#
# Edition Group   Edition Group     Collection          Work
#       |               |               |                |
#    Fascicle          Set          Page Image   Work's Image Group
#       |               |                                |
#     Sheet          (Sheet?)                        Page Image
#       |               |
#   Page Image      Page Image
#
# Work groups are a thing unto themselves, and don't fall into the hierarchy.
#
# Sheets will get the edition root as the parent for right now.  When we import
# fascicles, they'll become the sheet parent, and the fascicle parent will
# become the edition root.
#
# Collections are objective, so don't mix those with anything else.  This isn't
# exactly true, because collections as assigning order, which is subjective,
# and part of editions.  Maybe collections should be factored into editions.
#
# Typically, every image gets added to at least three groups: the edition group, and
# collection group, and the work group(s).
#
# Pages traverse the leafs of the edition image tree and the work list

require 'csv'
class HarvardImageImporter
    def import(directory, johnson_franklin_map)
        collection = Collection.create!(:name => 'Harvard Collection', :metadata => {'Library' => 'Houghton'})
        editions = Edition.where(:author => ['Thomas H. Johnson', 'R. W. Franklin'])

        Dir.open(directory).each do |filename|
            next if filename[0] == '.'
            file = File.open("#{directory}/#{filename}")
            doc = Nokogiri::XML(file)
            doc.remove_namespaces!

            # Create sheet group and add to edition
            # Don't create a sheet group if this file doesn't contain poems
            sheet_groups = editions.map{|e| new_sheet_group(e, doc) if doc_has_works?(e, doc, johnson_franklin_map)}
            next if sheet_groups.compact.empty?

            doc.css('structMap div[TYPE=PAGE]').each do |page|
                file_id = page.css('fptr')[1]['FILEID']
                image_url = doc.at(%Q|file[ID="#{file_id}"]|).at('FLocat')['href']
                next unless image_url && page['LABEL']
                image_url = image_url.match(/(ms_.*)\.jp2/)[1]
                web_file = Rails.root.join('app', 'assets', 'images', Eda::Application.config.emily['web_image_directory'], image_url + '.jpg').to_s
                width, height = `identify -format "%wx%h" "#{web_file}"`.split('x').map(&:to_i)
                image = Image.new(
                    :url => image_url,
                    :metadata => {'Imported' => Time.now.to_s},
                    :credits => 'Harvard credits',
                    :web_width => width,
                    :web_height => height
                )

                # Add same image to the collection group
                is = ImageSet.new
                is.image = image
                is.save!
                is.move_to_child_of collection

                editions.each_with_index do |edition, i|
                    next if sheet_groups[i].nil?
                    # Don't skip pages that don't have works because we'd like
                    # to see the backs of pages when page turning, etc.

                    # Create an image and add it to the sheet group
                    image_for_sheet_set = ImageSet.new
                    image_for_sheet_set.image = image
                    image_for_sheet_set.save!
                    image_for_sheet_set.move_to_child_of sheet_groups[i]

                    # Find the works contained in this image
                    works = works_from_page(edition, page, johnson_franklin_map)

                    next if works.empty?

                    # Create a page for every work this image contains
                    create_work_pages!(edition, works, image, image_for_sheet_set)
                end
            end
            sheet_groups.compact.each(&:save!)
            editions.each(&:save!)
            collection.save!
        end
        pageless_works.each do |work|
            puts "creating page for imageless work: #{work.number} #{work.variant}"
            create_work_page_without_image(work)
        end
    end

    def pageless_works
        Work.find(Work.all.map(&:id) - Page.all.map{|p| p.work.id if p.work_set}.compact)
    end

    def page_has_works?(editions, page, johnson_franklin_map)
        editions.any?{|e| !works_from_page(e, page, johnson_franklin_map).empty? }
    end

    def doc_has_works?(edition, doc, johnson_franklin_map)
        doc.css('structMap div[TYPE=PAGE]').any? do |page|
            !works_from_page(edition, page, johnson_franklin_map).empty?
        end
    end

    def new_sheet_group(edition, doc)
        is = ImageSet.create!(
            :name => doc.at('mets')['LABEL'],
            :editable => false,
            :metadata => {
                'Hollis ID' => doc.at_css('identifier[type="hollis"]').text,
                'URI' => doc.at_css('identifier[type="uri"]').text
            }
        )
        is.move_to_child_of edition.image_set
        is
    end

    def works_from_page(edition, page, johnson_franklin_map)
        label = page['LABEL']
        return [] unless label
        johnson = false
        if edition.author == 'Thomas H. Johnson'
            johnson = true
            f_j_map = Hash[CSV.read(johnson_franklin_map, {:headers => true, :converters => :integer}).to_a[1..-1]].invert
        end
        works = []
        call_number_pattern = /ms_am_1118_3_(\d{1,3})_\d{4}/
        call_number = page.css('fptr').first['FILEID']
        call_number_matches = call_number.match(call_number_pattern)
        franklin_numbers = label.scan(/Fr(\d{1,4})(\D|$)/)
        johnson_numbers = label.scan(/J(\d{1,4})(\D|$)/)
        work_numbers = johnson ? johnson_numbers : franklin_numbers
        work_numbers.each do |work_number|
            work_number = work_number[0].to_i
            next unless work_number
            if edition.works.where(:number => work_number).count > 1
                work = edition.works.where(:number => work_number).all.find do |w|
                    call_number_matches &&
                        w.metadata['holder_id'] &&
                        w.metadata['holder_code'] &&
                        w.metadata['holder_code'] == 'H' &&
                        w.metadata['holder_id'] == call_number_matches[1]
                end
                #puts "Multiple works in '#{edition.name}' with number #{work_number}"
                puts "Didn't pick a variant for #{work_number} with '#{call_number_matches}' from #{call_number}" unless work
            end
            # Just pull the first one
            works << (work ? work : edition.works.find_by_number(work_number))
        end
        works.compact!
        works
    end

    def create_work_page_without_image(work)
        page = work.edition.pages.new
        page.work_set = work.edition.work_set.leaf_containing(work)
        page.save!
    end

    def create_work_pages!(edition, works, image, image_for_sheet)
        works.each do |work|
            page = edition.pages.new
            page.image_set = image_for_sheet
            page.work_set = edition.work_set.leaf_containing(work)
            page.save!
        end
    end
end
