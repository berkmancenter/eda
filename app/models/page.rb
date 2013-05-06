class Page < ActiveRecord::Base
    belongs_to :edition
    belongs_to :work
    belongs_to :image_group_image
    # attr_accessible :title, :body

    alias_attribute :image, :image_group_image
end
