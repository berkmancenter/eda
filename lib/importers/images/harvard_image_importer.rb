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
        collection = Collection.new(:name => 'Harvard Collection', :metadata => {'Library' => 'Houghton'})
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
                image = Image.new(:url => image_url, :metadata => {'Imported' => Time.now.to_s}, :credits => 'Harvard credits')

                # Add same image to the collection group
                image_for_collection_group = collection.image_group_images.build(:position => collection.children.count)
                image_for_collection_group.image = image

                editions.each_with_index do |edition, i|
                    next if sheet_groups[i].nil?
                    # Don't skip pages that don't have works because we'd like
                    # to see the backs of pages when page turning, etc.

                    # Create an image and add it to the sheet group
                    image_for_sheet_group = sheet_groups[i].image_group_images.build(:position => page['ORDER'].to_i)
                    image_for_sheet_group.image = image

                    # Find the works contained in this image
                    works = works_from_label(edition, page['LABEL'], johnson_franklin_map)

                    next if works.empty?

                    # Create a page for every work this image contains
                    create_work_pages!(edition, works, image, image_for_sheet_group)
                end
            end
            sheet_groups.compact.each(&:save!)
            editions.each(&:save!)
            collection.save!
        end
    end

    def page_has_works?(editions, page, johnson_franklin_map)
        editions.any?{|e| !works_from_label(e, page['LABEL'], johnson_franklin_map).empty? }
    end

    def doc_has_works?(edition, doc, johnson_franklin_map)
        doc.css('structMap div[TYPE=PAGE]').any? do |page|
            !works_from_label(edition, page['LABEL'], johnson_franklin_map).empty?
        end
    end

    def new_sheet_group(edition, doc)
        edition.root_image_group.children.new(
            :name => doc.at('mets')['LABEL'],
            :editable => false,
            :metadata => {
                'Hollis ID' => doc.at_css('identifier[type="hollis"]').text,
                'URI' => doc.at_css('identifier[type="uri"]').text
            }
        )
    end

    def works_from_label(edition, label, johnson_franklin_map)
        return [] unless label
        johnson = false
        if edition.author == 'Thomas H. Johnson'
            johnson = true
            f_j_map = Hash[CSV.read(johnson_franklin_map, {:headers => true, :converters => :integer}).to_a[1..-1]].invert
        end
        works = []
        franklin_numbers = label.scan(/Fr(\d{1,4})(\D|$)/)
        johnson_numbers = label.scan(/J(\d{1,4})(\D|$)/)
        work_numbers = johnson ? johnson_numbers : franklin_numbers
        work_numbers.each do |work_number|
            work_number = work_number[0].to_i
            next unless work_number
            if edition.works.where(:number => work_number).count > 1
                puts "Multiple works in '#{edition.name}' with number #{work_number}"
            end
            # Just pull the first one
            works << edition.works.find_by_number(work_number)
        end
        works.compact!
        works
    end

    def create_work_pages!(edition, works, image, image_for_sheet)
        works.each do |work|
            page = edition.pages.new
            page.image = image_for_sheet
            page.work = work
            unless work.image_group
                work.image_group = ImageGroup.new(:name => "Images for #{work.title}")
            end
            work_group_image = work.image_group.image_group_images.new(:position => work.image_group.image_group_images.count)
            work_group_image.image = image
            work.save!
            page.save!
        end
    end
end
