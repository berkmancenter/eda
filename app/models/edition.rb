class Edition < ActiveRecord::Base
    belongs_to :owner
    has_many :works
    belongs_to :root_image_group, :class_name => 'ImageGroup'
    has_many :image_groups
    has_many :pages
    attr_accessible :author, :completeness, :date, :description, :name, :work_number_prefix

    def work_after(work)
        works.where{number > work.number}.order(:number).first
    end

    def image_group_after(image_group)
        next_image_group = nil
        while !next_image_group && image_group != root_image_group
            next_image_group = image_group.right_sibling
            image_group = image_group.parent
        end
        next_image_group
    end

    def image_after(image_group_image)
        current_image_group = image_group_image.image_group
        next_image = current_image_group.image_after(image_group_image)
        next_image = image_group_after(current_image_group).image_group_images.first unless next_image
    end
end
