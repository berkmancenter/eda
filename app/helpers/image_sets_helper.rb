module ImageSetsHelper
    def cache_key_for_image_sets(image_sets)
        count          = image_sets.count
        max_updated_at = image_sets.maximum(:updated_at).try(:utc).try(:to_s, :number)
        "image_sets/many-#{count}-#{max_updated_at}"
    end
end
