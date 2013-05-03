class ImageGroupImage < ActiveRecord::Base
  belongs_to :image_group
  belongs_to :image
  attr_accessible :position
end
