class Page < ActiveRecord::Base
    belongs_to :edition
    belongs_to :work
    belongs_to :image_group_image
    # attr_accessible :title, :body

    alias_attribute :image, :image_group_image

    def image_url
        image_group_image.image.url
    end

    def next
        next_work = Work.find_by_number(work.number + 1)
        current_image_group = image.image_group
        next_image = current_image_group.images.find_by_position(image.position + 1)
        while !next_image && current_image_group.parent
            next_image = current_image_group.parent.images.find_by_position(current_image_group.position + 1)
            current_image_group = current_image_group.parent
        end
        return unless next_work || next_image
        if next_work && !next_image
            # We're at the last image in the collection, but there's at least
            # one additional work without an associated image
        elsif next_image && !next_work
            # We're at the last work in the collection, but there's at least
            # one more image without an associated work
        else
            next_works_image = next_work.image_group.images.first.image
            next_images_work = next_image.image_group.work
            if next_works_image == image.image
                # We're looking at an image with multiple works on it
                next_work_id = nil #TODO
                next_image_id = image.id
                return Page.find_by_work_id_and_image_group_image_id( next_work_id, next_image_id )
            elsif next_images_work == work
                # We're looking at a work spanning multiple images
                return Page.find_by_work_id_and_image_group_image_id( work.id, next_image.id )
            end
        end

    end

    def previous
    end
end
