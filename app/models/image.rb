class Image < ActiveRecord::Base
    has_many :sets, class_name: 'ImageSet'
    has_many :notes, :as => :notable
    attr_accessible :credits, :url, :metadata, :web_width, :web_height
    serialize :metadata
end
