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

class HarvardImageImporter
    def import(directory)
        collection = Collection.new(:name => 'Harvard Collection', :metadata => {'Library' => 'Houghton'})
        edition = Edition.find_by_author('R. W. Franklin')
        Dir.open(directory).each do |filename|
            next if filename[0] == '.'
            file = File.open("#{directory}/#{filename}")
            puts filename
            doc = Nokogiri::XML(file)
            doc.remove_namespaces!

            # Create sheet group and add to edition
            sheet_group = edition.root_image_group.children.new(
                :name => doc.at('mets')['LABEL'],
                :editable => false,
                :metadata => {
                    'Hollis ID' => doc.at_css('identifier[type="hollis"]').text,
                    'URI' => doc.at_css('identifier[type="uri"]').text
                }
            )

            doc.css('structMap div[TYPE=PAGE]').each do |page|
                file_id = page.css('fptr')[1]['FILEID']
                image_url = doc.at(%Q|file[ID="#{file_id}"]|).at('FLocat')['href']
                next unless image_url && page['LABEL']

                # Create an image and add it to the sheet group
                image = Image.new(:url => image_url, :metadata => {'Imported' => Time.now.to_s}, :credits => 'Harvard credits')
                image_for_sheet_group = sheet_group.image_group_images.build(:position => page['ORDER'].to_i)
                image_for_sheet_group.image = image

                # Add same image to the collection group
                image_for_collection_group = collection.image_group_images.build(:position => collection.children.count)
                image_for_collection_group.image = image

                # Find the works contained in this image
                works = []
                franklin_numbers = page['LABEL'].scan(/Fr(\d{1,4})\D/)
                puts franklin_numbers.inspect
                franklin_numbers.each do |franklin_number|
                    if Work.where(:number => franklin_number[0]).count > 1
                        puts "Multiple works with number #{franklin_number[0]}"
                    end
                    works << Work.find_by_number(franklin_number[0])
                end
                puts works.inspect
                works.compact!

                # Create a page without a work if we don't have one
                if works.empty?
                    page = edition.pages.new
                    page.image = image_for_sheet_group
                    page.save!
                end

                # Create a page for every work this image contains
                works.each do |work|
                    page = edition.pages.new
                    page.image = image_for_sheet_group
                    page.work = work
                    unless work.image_group
                        work.image_group = ImageGroup.new(:name => "Images for #{work.title}", :position => 0)
                    end
                    work_group_image = work.image_group.images.new(:position => work.image_group.images.count)
                    work_group_image.image = image
                    work.save!
                    page.save!
                end
            end
            edition.save!
            collection.save!
        end
    end
end
