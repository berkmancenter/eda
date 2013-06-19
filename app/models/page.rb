class Page < ActiveRecord::Base
    belongs_to :edition
    belongs_to :work
    belongs_to :image_group_image

    alias_attribute :image, :image_group_image

    def image_url
        image_group_image.image.url
    end

    # We're going to be thumbing through the pages of an edition.
    def next
        next_work = edition.work_after(work) if work
        next_image = edition.image_after(image) if image

        return unless next_work || next_image
        if next_work && !next_image
            # We're at the last image in the edition, but there's at least
            # one additional work without an associated image
            return edition.pages.find_by_work_id_and_image_group_image_id(next_work.id, nil)
        elsif next_image && !next_work
            # We're at the last work in the edition, but there's at least
            # one more image without an associated work
            return edition.pages.find_by_work_id_and_image_group_image_id(nil, next_image.id)
        else
            # We've got options for both a next work and a next image
            next_works_image = next_work.image_group.images.first.image if next_work.image_group
            next_images_work = next_image.image_group.work
            if next_works_image == image.image
                # We're looking at an image with multiple works on it
                return Page.find_by_work_id_and_image_group_image_id( next_work.id, image.id )
            elsif next_images_work == work
                # We're looking at a work spanning multiple images
                return Page.find_by_work_id_and_image_group_image_id( work.id, next_image.id )
            end
        end

    end

    def previous
    end
end
