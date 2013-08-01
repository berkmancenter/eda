class Image < ActiveRecord::Base
    has_many :sets, class_name: 'ImageSet'
    attr_accessible :credits, :url, :metadata, :web_width, :web_height
    serialize :metadata
end
