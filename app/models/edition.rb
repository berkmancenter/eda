class Edition < ActiveRecord::Base
    belongs_to :owner
    has_many :works
    belongs_to :root_image_group, :class_name => 'ImageGroup'
    has_many :image_groups
    has_many :pages
    attr_accessible :author, :completeness, :date, :description, :name, :work_number_prefix

    def work_after(work)
        works.where{
            (number > work.number) | ((number == work.number) & (variant > work.variant))
        }.order(:number, :variant).first
    end

    def work_before(work)
        works.where{
            (number < work.number) | ((number == work.number) & (variant < work.variant))
        }.order('number DESC, variant DESC').first
    end

    def image_group_after(image_group)
        igs = []
        ImageGroup.each_with_level(image_group.root.self_and_descendants) do |ig, level|
            igs << ig
        end
        next_image_group = nil
        index_of_next = igs.index(image_group) + 1
        next_image_group = igs[index_of_next] if igs[index_of_next]
        next_image_group
    end

    def image_after(image_group_image)
        current_image_group = image_group_image.image_group
        next_image = current_image_group.image_after(image_group_image)
        next_image = image_group_after(current_image_group).image_group_images.first unless next_image
        next_image
    end

    def images_of_work(work)
        return unless work.image_group
        ImageGroupImage.where(
            :image_group_id => root_image_group.self_and_descendants.map(&:id),
            :image_id => work.image_group.image_group_images.map{|igi| igi.image.id}
        )
    end

    def image_group_image_from_image(image)
        ImageGroupImage.where(
            :image_group_id => root_image_group.self_and_descendants.map(&:id),
            :image_id => image.id
        ).first
    end

    def works_in_image(image)
        Work.joins(:image_group => :image_group_images).where(
            :image_groups => {
                :image_group_images => {
                    :image_id => image.image.id
                }
            }
        )
    end
end
