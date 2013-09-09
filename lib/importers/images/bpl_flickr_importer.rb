# Pull down the images to the filesystem
# Create an image object
# Put that image in the BPL Collection
# For each edition, add the image to the root image group and
# put that image object in with the Work's image group
# (matched off Johnson number)

require 'csv'
class BPLFlickrImporter
    BPL_PHOTOSET_ID = '72157604466722178'
    PER_PAGE = 500
    def import(image_dir)
        puts 'Importing BPL images from Flickr'
        collection = Collection.create(:name => 'Boston Public Library', :metadata => {'Library' => 'BPL'})
        FlickRaw.api_key="1a639ffd8be5ff472f5aa4889f447082"
        FlickRaw.shared_secret="95eb6034f3da44c3"
        pattern = /<b>(?<key>.*):<\/b> (?<value>.*)$/
        total_pages = 0
        current_page = 1

        loop do 
            response = flickr.photosets.getPhotos(
                :photoset_id => BPL_PHOTOSET_ID,
                :extras => 'o_dims,url_o',
                :per_page => PER_PAGE,
                :page => current_page
            )
            total_pages = response.pages
            puts "Page #{current_page} of #{total_pages}"
            photos = response.photo
            photos.each_with_index do |photo, i|
                sleep 1
                puts "#{i + 1 + (current_page - 1) * PER_PAGE} / #{response.total}"
                metadata = {}
                photoInfo = flickr.photos.getInfo(:photo_id => photo.id)
                next if File.exists?("#{image_dir}/#{photoInfo.id}_#{photoInfo.originalsecret}_o.jpg")
                photoInfo.description.split(/\n\n/).each do |unruly_metadata|
                    if matches = unruly_metadata.match(pattern)
                        metadata[matches[:key]] = matches[:value]
                    end
                end
                url = photo.url_o
                output = `wget -nv -P "#{image_dir}" #{url} 2>&1`
                file = output.match(/-> "(.*\.jpg)/)[1]
                filename = File.basename(file, '.jpg')
                image = Image.create(
                    :url => filename,
                    :credits => 'Boston Public Library',
                    :metadata => metadata
                )
                collection << image
            end
            break if current_page == total_pages
            current_page += 1
        end
        collection.save!
    end
end
