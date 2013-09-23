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
        pbar = nil
        info_file_path = File.join(Eda::Application.config.emily['data_directory'], 'bpl_photo_info.bin')
        if File.size? info_file_path
            photo_infos = Marshal.load(File.open(info_file_path)) 
        else
            photo_infos = {}
        end

        loop do 
            response = flickr.photosets.getPhotos(
                :photoset_id => BPL_PHOTOSET_ID,
                :extras => 'o_dims,url_o',
                :per_page => PER_PAGE,
                :page => current_page
            )
            pbar = ProgressBar.new("BPL-Flickr", response.total.to_i) unless pbar
            total_pages = response.pages
            photos = response.photo
            photos.each_with_index do |photo, i|
                sleep 1.5 + Random.rand
                pbar.inc
                metadata = {}
                if photo_infos[photo.id]
                    photoInfo = photo_infos[photo.id]
                else
                    photoInfo = flickr.photos.getInfo(:photo_id => photo.id)
                    photo_infos[photo.id] = photoInfo
                    info_file = File.open(info_file_path, 'wb')
                    Marshal.dump(photo_infos, info_file)
                    info_file.close
                end
                photoInfo.description.split(/\n\n/).each do |unruly_metadata|
                    if matches = unruly_metadata.match(pattern)
                        metadata[matches[:key]] = matches[:value]
                    end
                end
                filename = "#{photoInfo.id}_#{photoInfo.originalsecret}_o.jpg"
                unless File.exists?(File.join(image_dir, filename))
                    url = photo.url_o
                    output = `wget -nv -P "#{image_dir}" #{url} 2>&1`
                end
                image = Image.create(
                    :url => File.basename(filename, '.jpg'),
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
