class WorkPageGroup < ActiveRecord::Base
  belongs_to :work
  belongs_to :page_group
  # attr_accessible :title, :body
end
