class Edition < ActiveRecord::Base
    belongs_to :owner
    has_many :works
    belongs_to :root_image_group, :class_name => 'ImageGroup'
    has_many :image_groups
    has_many :pages
    attr_accessible :author, :completeness, :date, :description, :name, :work_number_prefix

    def image_group_image_from_image(image)
        ImageGroupImage.where(
            :image_group_id => root_image_group.self_and_descendants.map(&:id),
            :image_id => image.id
        ).first
    end

    def images_of_work(work)
        return unless work.image_group
        ImageGroupImage.where(
            :image_group_id => root_image_group.self_and_descendants.map(&:id),
            :image_id => work.image_group.image_group_images.map{|igi| igi.image.id}
        )
    end

    def works_in_image(image)
        works.joins(:image_group => :image_group_images).where(
            :image_groups => {
                :image_group_images => {
                    :image_id => image.id
                }
            }
        )
    end
end
