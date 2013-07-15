class WorkGroup < ActiveRecord::Base
  belongs_to :parent_group
  belongs_to :edition
  belongs_to :owner, :class_name => 'User'
  has_many :work_group_works
  has_many :works, :through => :work_group_works
  attr_accessible :name, :position, :type
end
