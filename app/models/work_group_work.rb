class WorkGroupWork < ActiveRecord::Base
  belongs_to :work_group
  belongs_to :work
  attr_accessible :position
end
