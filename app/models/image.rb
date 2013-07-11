class Image < ActiveRecord::Base
    has_many :image_group_images
    has_many :image_groups, :through => :image_group_images
    has_many :notes, :as => :notable
    attr_accessible :credits, :url, :metadata, :web_width, :web_height
    serialize :metadata
end
