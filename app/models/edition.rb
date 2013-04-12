class Edition < ActiveRecord::Base
  belongs_to :owner
  attr_accessible :author, :completeness, :date, :description, :name, :work_number_prefix
end
