class Edition < ActiveRecord::Base
  belongs_to :owner
  has_many :works
  belongs_to :root_image_group, :class_name => 'ImageGroup'
  has_many :image_groups
  has_many :pages
  attr_accessible :author, :completeness, :date, :description, :name, :work_number_prefix
end
