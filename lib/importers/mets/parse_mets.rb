# Collection
# Fascicle
# Work Images
# Don't forget positions

class MetsImporter
    def import(directory)
        collection = Collection.new(:name => 'Harvard Collection', :metadata => {'Library' => 'Houghton'})
        edition = Edition.find_by_author('R. W. Franklin')
        Dir.open(directory).each do |filename|
            file = File.open("#{directory}/#{filename}")
            doc = Nokogiri::XML(file)
            doc.css('structMap div[TYPE=PAGE]').each do |page|
                next unless page['LABEL']
                franklin_number = page['LABEL'].match(/Fr(\d{1,4})/)
                fid = page.css('fptr')[1]['FILEID']
                image_url = doc.at(%Q|file[ID="#{fid}"]|).at('FLocat')['xlink:href']
                next unless image_url
                image = Image.new(:image_url => image_url, :metadata => {'Imported' => Time.now.to_s}, :credits => 'Harvard credits')
                work = Work.find_by_number(franklin_number[1]) if franklin_number
                pg = Page.new
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
                if work
                    collection.children << ig
                    collection.save!
                end
            end
        end
    end
end
