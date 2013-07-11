class Page < ActiveRecord::Base
    belongs_to :edition
    belongs_to :work
    belongs_to :image_group_image

    alias_attribute :image, :image_group_image

    def image_url
        image_group_image.image.url
    end

    def next
        # The current work continues onto another image
        if image_group_image && works_next_image = work.image_after(image_group_image.image)
            igi = edition.image_group_image_from_image(works_next_image)
            return Page.with_work_and_image(work, igi)
        end

        # Head on to the next work
        if next_work = edition.work_after(work)
            igis = next_work.image_group_images

            # Head to an imageless page if we don't have an image
            return Page.with_imageless_work(next_work) if igis.empty?

            bare_image = igis.order(:position).first.image
            return Page.with_work_and_image(
                next_work,
                edition.image_group_image_from_image(bare_image)
            )
        end
    end

    def previous
        if image_group_image && works_previous_image = work.image_before(image_group_image.image)
            igi = edition.image_group_image_from_image(works_previous_image)
            return Page.with_work_and_image(work, igi)
        end

        if previous_work = edition.work_before(work)
            igis = previous_work.image_group_images
            return Page.with_imageless_work(previous_work) if igis.empty?
            bare_image = igis.order('position DESC').first.image
            return Page.with_work_and_image(
                previous_work,
                edition.image_group_image_from_image(bare_image)
            )
        end
    end

    def self.with_imageless_work(work)
        where(:work_id => work.id, :image_group_image_id => nil).first
    end

    def self.with_work_and_image(work, igi)
        where(:work_id => work.id, :image_group_image_id => igi.id).first
    end
end
