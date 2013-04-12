class WorkGroup < ActiveRecord::Base
  belongs_to :parent_group
  belongs_to :edition
  belongs_to :owner
  attr_accessible :name, :position, :type
end
