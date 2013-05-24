class Image < ActiveRecord::Base
  attr_accessible :credits, :url, :metadata
  serialize :metadata
end
