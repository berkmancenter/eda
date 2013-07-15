class ImageGroupImage < ActiveRecord::Base
    belongs_to :image_group
    belongs_to :image
    attr_accessible :position
    default_scope order(:position)
end
