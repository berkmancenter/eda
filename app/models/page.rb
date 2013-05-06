class Page < ActiveRecord::Base
  belongs_to :work
  belongs_to :image_group_image
  # attr_accessible :title, :body
end
