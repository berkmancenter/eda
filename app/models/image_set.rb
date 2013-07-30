class ImageSet < Sett
    alias_attribute :image, :nestable

    def image=(image)
        self.nestable = image
    end

    def all_images
        self_and_descendants.map{|image_set| image_set.image}.compact
    end
end
