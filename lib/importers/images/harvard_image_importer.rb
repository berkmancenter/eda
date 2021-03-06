require 'csv'
class HarvardImageImporter
    def import(directory, johnson_franklin_map, exclude_list, max_images = nil)
        puts "Importing Harvard images"
        collection = Collection.create!(:name => 'Houghton Library')
        collection.metadata = {
            'URL' => 'http://hcl.harvard.edu/libraries/houghton/collections/modern/dickinson.cfm',
            'Long Name' => 'Houghton Library, Harvard University,  Cambridge, MA',
            'Code' => 'H,HCL'
        }
        image_count = 0
        total_files = Dir.entries(directory).count
        pbar = ProgressBar.new("Harvard Img", total_files)
        images_to_exclude = CSV.read(exclude_list).flatten.compact.map(&:strip)

        Dir.open(directory).each_with_index do |filename, i|
            pbar.inc
            next if filename[0] == '.'
            next if max_images && image_count >= max_images
            file = File.open("#{directory}/#{filename}")
            doc = Nokogiri::XML(file)
            doc.remove_namespaces!

            # Create sheet group and add to edition
            sheet_group = new_sheet_group(collection, doc)

            doc.css('structMap div[TYPE=PAGE]').each do |page|
                file_id = page.css('fptr')[1]['FILEID']
                image_url = doc.at(%Q|file[ID="#{file_id}"]|).at('FLocat')['href']
                next unless image_url && page['LABEL']
                if match = image_url.match(/(ms_.*)\.jp2/)
                    image_url = match[1]
                else
                    next
                end
                next if images_to_exclude.include?(image_url)
                image = Image.new(
                    :title => "Houghton Library - #{page['LABEL']}",
                    :url => image_url,
                    :credits => 'Harvard credits',
                    :metadata => {
                        'Imported' => Time.now.to_s,
                        'Order' => page['ORDER'].to_i,
                        'Order Label' => page['ORDERLABEL'],
                        'Label' => page['LABEL'],
                        'Filename' => image_url
                    }
                )
                image_count += 1

                sheet_group << image
            end
            sheet_group.destroy if sheet_group.all_images.empty?
        end
        collection.save!
    end

    def new_sheet_group(collection, doc)
        is = ImageSet.create!(
            :name => doc.at('mets')['LABEL'],
            :editable => false,
            :metadata => {
            'Hollis ID' => doc.at_css('identifier[type="hollis"]').text,
            'URI' => doc.at_css('identifier[type="uri"]').text
        }
        )
        is.move_to_child_of collection
        is
    end
end
