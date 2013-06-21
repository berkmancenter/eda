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
    def import(image_dir, johnson_franklin_map)
        j_f_map = Hash[CSV.read(johnson_franklin_map, {:headers => true, :converters => :integer}).to_a[1..-1]]
        collection = Collection.new(:name => 'Boston Public Library', :metadata => {'Library' => 'BPL'})
        editions = Edition.where(:author => ['Thomas H. Johnson', 'R. W. Franklin'])
        FlickRaw.api_key="1a639ffd8be5ff472f5aa4889f447082"
        FlickRaw.shared_secret="95eb6034f3da44c3"
        pattern = /<b>(?<key>.*):<\/b> (?<value>.*)$/
        johnson_key = 'Identifier (Johnson Poem #)'
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
                puts "#{i + 1 + (current_page - 1) * PER_PAGE} / #{response.total}"
                metadata = {}
                photoInfo = flickr.photos.getInfo(:photo_id => photo.id)
                photoInfo.description.split(/\n\n/).each do |unruly_metadata|
                    if matches = unruly_metadata.match(pattern)
                        metadata[matches[:key]] = matches[:value]
                    end
                end
                johnson_number = metadata[johnson_key].to_i
                next unless johnson_number && has_works?(editions, johnson_number, j_f_map)
                url = photo.url_o
                output = `wget -nv -P "#{image_dir}" #{url} 2>&1`
                file = output.match(/-> "(.*\.jpg)/)[1]
                filename = File.basename(file, '.jpg')
                image = Image.create(
                    :url => filename,
                    :credits => 'Boston Public Library',
                    :metadata => metadata
                )
                # Add the image to the collection
                image_for_collection_group = collection.image_group_images.build(
                    :position => collection.children.count
                )
                image_for_collection_group.image = image

                editions.each do |edition|
                    work = get_work(edition, johnson_number, j_f_map)
                    next unless work
                    # Add image to edition group
                    image_for_edition_group = edition.root_image_group.image_group_images.build(
                        :position => edition.root_image_group.image_group_images.count
                    )
                    image_for_edition_group.image = image

                    create_work_pages!(edition, [work], image, image_for_edition_group)
                end
            end
            break if current_page == total_pages
            current_page += 1
        end
        collection.save!
    end

    def has_works?(editions, number, johnson_franklin_map)
        editions.any?{|e| !!get_work(e, number, johnson_franklin_map) }
    end

    def get_work(edition, johnson_number, johnson_franklin_map)
        johnson = edition.author == 'Thomas H. Johnson'
        work = nil
        #TODO: Do BPL images have multiple works in a single image?
        if johnson
            work = edition.works.find_by_number(johnson_number)
        else
            franklin_number = johnson_franklin_map[johnson_number].to_i
            work = edition.works.find_by_number(franklin_number) if franklin_number
        end
        work
    end

    def create_work_pages!(edition, works, image, image_for_group)
        works.each do |work|
            page = edition.pages.new
            page.image = image_for_group
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
