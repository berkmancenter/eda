class ImageGroup < ActiveRecord::Base
    belongs_to :edition
    has_many :image_group_images, :order => :position
    has_one :work
    attr_accessible :editable, :image_url, :metadata, :name, :type
    serialize :metadata
    acts_as_nested_set
    include TheSortableTree::Scopes

    def image_after(image)
        image_group_images.where{position > image.position}.order(:position).first
    end

    def images
        self_and_descendants.map{|ig| ig.image_group_images.map(&:image)}.flatten
    end
end
