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
        logger.info("Next work: #{next_work.id if next_work} - Next Image: #{next_image.id if next_image}")

        return unless next_work || next_image
        return edition.pages.find_by_work_id_and_image_group_image_id(next_work.id, nil) if next_work && next_image.nil?
        return edition.pages.find_by_work_id_and_image_group_image_id(nil, next_image.id) if next_image && next_work.nil?

        images_of_next_work = edition.images_of_work(next_work)
        works_in_next_image = edition.works_in_image(next_image)

        next_works_first_image = images_of_next_work.order(:position).first
        next_images_first_work = works_in_next_image.order(:number).first

        logger.info("Next image's first work: #{next_images_first_work.id if next_images_first_work} - Next work's first image: #{next_works_first_image.id if next_works_first_image}")

        return Page.find_by_work_id_and_image_group_image_id( work.id, next_image.id ) \ 
            if next_images_first_work == work && next_works_first_image != image

        return Page.find_by_work_id_and_image_group_image_id( next_work.id, image.id ) \
            if next_works_first_image.image == image.image && next_images_first_work != work

        return Page.find_by_work_id_and_image_group_image_id(next_work.id, next_works_first_image.id) \
            if next_works_first_image && next_images_first_work.nil?

        return Page.find_by_work_id_and_image_group_image_id( next_images_first_work.id, next_image.id ) \
            if next_images_first_work && next_works_first_image.nil?

        return Page.find_by_work_id_and_image_group_image_id( next_work.id, next_image.id ) \
            if next_images_first_work == next_work && next_works_first_image == next_image
    end

    def previous
    end
end
