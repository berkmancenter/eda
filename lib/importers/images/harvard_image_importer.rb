require 'csv'
class HarvardImageImporter
    def import(directory, johnson_franklin_map, max_images = nil)
        puts "Importing Harvard images"
        collection = Collection.create!(:name => 'Harvard University, Houghton Library')
        image_count = 0
        total_files = Dir.entries(directory).count
        pbar = ProgressBar.new("Harvard Img", total_files)

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
                image = Image.new(
                    :title => "Houghton Library - #{page['Label']}",
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
