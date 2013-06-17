class BPLFlickrImporter
    BPL_PHOTOSET_ID = '72157604466722178'
    def import(image_dir)
        FlickRaw.api_key="1a639ffd8be5ff472f5aa4889f447082"
        FlickRaw.shared_secret="95eb6034f3da44c3"
        pattern = /<b>(?<key>.*):<\/b> (?<value>.*)$/

        photos = flickr.photosets.getPhotos(:photoset_id => BPL_PHOTOSET_ID, :extras => 'o_dims,url_o', :per_page => 3).photo
        photos.each do |photo|
            #photoInfo = flickr.photos.getInfo(:photo_id => photo.id)
            url = photo.url_o
            `wget -P "#{image_dir}" #{url}`
            #photoInfo.description.split(/\n\n/).each do |metadata|
            #    if matches = metadata.match(pattern)
            #        puts matches.inspect
            #    end
            #end
        end
    end
end
