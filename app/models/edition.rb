class Edition < ActiveRecord::Base
  belongs_to :owner
  has_many :works
  has_many :image_groups
  attr_accessible :author, :completeness, :date, :description, :name, :work_number_prefix
end
