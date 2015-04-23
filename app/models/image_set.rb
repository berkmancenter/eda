# == Schema Information
#
# Table name: setts
#
#  id             :integer          not null, primary key
#  name           :text
#  metadata       :text
#  type           :string(255)
#  editable       :boolean
#  nestable_id    :integer
#  nestable_type  :string(255)
#  owner_id       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  level_order    :integer
#  ancestry       :string(255)
#  is_leaf        :boolean          default(TRUE)
#  ancestry_depth :integer          default(0)
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
        if output = read_attribute(:name)
            output
        elsif image && image.title
            image.title
        end
    end

    def <<(image)
        save! if changed?
        is = self.class.new
        is.image = image
        is.save!
        is.move_to_child_of self
        is.save!
        save! if changed?
        is
    end

    def all_images
        self_and_descendants.map{|image_set| image_set.image}.compact
    end

    def collection
      parent = self.parent
      while !parent.nil? do
        return parent if parent.is_a? Collection
        parent = parent.parent
      end
    end
end
