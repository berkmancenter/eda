class Image < ActiveRecord::Base
    has_many :image_group_images
    has_many :image_groups, :through => :image_group_images
    attr_accessible :credits, :url, :metadata
    serialize :metadata
end
