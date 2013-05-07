class ImageGroup < ActiveRecord::Base
  belongs_to :parent_group, :class_name => 'ImageGroup'
  belongs_to :edition
  has_many :image_group_images
  has_many :children, :class_name => 'ImageGroup', :foreign_key => 'parent_group_id'
  has_many :images, :through => :image_group_images
  has_one :work
  attr_accessible :editable, :image_url, :metadata, :name, :position, :type
  serialize :metadata
  alias_attribute :images, :image_group_images
end
