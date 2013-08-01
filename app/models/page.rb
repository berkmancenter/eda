# == Schema Information
#
# Table name: pages
#
#  id           :integer          not null, primary key
#  edition_id   :integer
#  work_set_id  :integer
#  image_set_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Page < ActiveRecord::Base
    belongs_to :edition
    belongs_to :work_set
    belongs_to :image_set

    def work
        work_set.work if work_set
    end

    def image
        image_set.image if image_set
    end

    def next
        edition.pages.with_work(work_set.right_sibling.work).first if work_set and work_set.right_sibling
    end

    def previous
        edition.pages.with_work(work_set.left_sibling.work).first if work_set and work_set.left_sibling
    end

    def self.with_imageless_work(work)
        where(work_set_id: edition.work_set.leaf_containing(work).id, image_set_id: nil).first
    end

    def self.with_work_and_image(work_set, image_set)
        work_set = edition.work_set.leaf_containing(work) unless work_set.is_a? WorkSet
        image_set = edition.image_set.leaf_containing(image) unless image_set.is_a? ImageSet
        where(work_set: work_set, image_set: image_set).first
    end
end
