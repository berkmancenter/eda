class Page < ActiveRecord::Base
    belongs_to :edition
    belongs_to :work
    belongs_to :image_group_image

    scope :find_by_ids, lambda { |work_id, igi_id|
        where(:work_id => work_id, :image_group_image_id => igi_id)
    }

    alias_attribute :image, :image_group_image

    def image_url
        image_group_image.image.url
    end

    # We're going to be thumbing through the pages of an edition.
    def next
        if image && works_next_image = work.image_after(image.image)
            igi = edition.image_group_image_from_image(works_next_image)
            return Page.find_by_ids(work.id, igi.id).first
        elsif next_work = edition.work_after(work)
            igis = next_work.image_group_images
            if igis.empty?
                return Page.find_by_ids(next_work.id, nil).first
            else
                bare_image = igis.order(:position).first.image
                return Page.find_by_ids(
                    next_work.id, edition.image_group_image_from_image(bare_image).id
                ).first
            end
        end
    end

    def previous
    end
end
