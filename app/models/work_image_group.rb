class WorkImageGroup < ActiveRecord::Base
  belongs_to :work
  belongs_to :image_group
  # attr_accessible :title, :body
end
