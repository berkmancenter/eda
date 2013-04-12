class PageGroupPage < ActiveRecord::Base
  belongs_to :page_group
  belongs_to :page
  attr_accessible :position
end
