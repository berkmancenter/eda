class Work < ActiveRecord::Base
  belongs_to :edition
  belongs_to :page_group
  attr_accessible :date, :metadata, :number, :title
end
