# == Schema Information
#
# Table name: setts
#
#  id            :integer          not null, primary key
#  name          :text
#  metadata      :text
#  type          :string(255)
#  editable      :boolean
#  parent_id     :integer
#  lft           :integer
#  rgt           :integer
#  depth         :integer
#  nestable_id   :integer
#  nestable_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ImageSet < Sett
    alias_attribute :image, :nestable
    has_many :editions, foreign_key: 'image_set_id'
    has_many :works

    def leaves_showing_work(work)
        leaves.where(nestable_id: work.image_set.all_images.map(&:id), nestable_type: 'Image')
    end

    def image=(image)
        self.nestable = image
    end

    def name
        read_attribute(:name) || image.metadata['Label']
    end

    def <<(image)
        save! if changed?
        id = children.create(type: 'ImageSet').id
        is = ImageSet.find(id)
        is.image = image
        is.save!
        save! if changed?
    end

    def all_images
        self_and_descendants.map{|image_set| image_set.image}.compact
    end
end
