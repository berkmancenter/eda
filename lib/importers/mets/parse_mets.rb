# Collection
# Fascicle
# Work Images
# Sheets
# Don't forget positions

class MetsImporter
    def import(directory)
        collection = Collection.new(:name => 'Harvard Collection', :metadata => {'Library' => 'Houghton'})
        edition = Edition.find_by_author('R. W. Franklin')
        Dir.open(directory).each do |filename|
            next if filename[0] == '.'
            file = File.open("#{directory}/#{filename}")
            puts filename
            doc = Nokogiri::XML(file)
            doc.remove_namespaces!
            sheet_group = ImageGroup.new(:name => doc.at('mets')['LABEL'], :editable => false, :metadata => {'Hollis ID' => doc.at_css('identifier[type="hollis"]').text, 'URI' => doc.at_css('identifier[type="uri"]').text})
            doc.css('structMap div[TYPE=PAGE]').each do |page|
                next unless page['LABEL']
                franklin_number = page['LABEL'].match(/Fr(\d{1,4})/)
                fid = page.css('fptr')[1]['FILEID']
                image_url = doc.at(%Q|file[ID="#{fid}"]|).at('FLocat')['href']
                next unless image_url
                image = Image.new(:url => image_url, :metadata => {'Imported' => Time.now.to_s}, :credits => 'Harvard credits')
                igi = sheet_group.image_group_images.build(:position => page['ORDER'].to_i)
                igi.image = image
                work = Work.find_by_number(franklin_number[1]) if franklin_number
                pg = Page.new
                pg.edition = edition
                if work
                    pg.work = work
                    unless ig = work.image_group
                        ig = ImageGroup.new(:name => "#{work.title} images", :position => collection.children.count)
                        ig.edition = edition
                        work.image_group = ig
                        work.save!
                    end
                else
                    ig = collection
                end
                igi = ImageGroupImage.new(:position => ig.image_group_images.count)
                igi.image = image
                pg.image_group_image = igi
                ig.image_group_images << igi
                ig.save!
                pg.save!
                if work
                    collection.children << ig
                    collection.save!
                end
            end
            sheet_group.save!
        end
    end
end
