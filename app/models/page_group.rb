class PageGroup < ActiveRecord::Base
  belongs_to :parent_group
  belongs_to :edition
  attr_accessible :editable, :image_url, :metadata, :name, :position, :type
end
