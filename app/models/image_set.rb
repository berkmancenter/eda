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

    def image=(image)
        self.nestable = image
    end

    def <<(image)
        is = ImageSet.new
        is.image = image
        is.save!
        is.move_to_child_of self
    end

    def all_images
        self_and_descendants.map{|image_set| image_set.image}.compact
    end
end
