module CollectionsHelper
    def cache_key_for_collections(collections)
        count          = collections.count
        max_updated_at = collections.maximum(:updated_at).try(:utc).try(:to_s, :number)
        "collections/many-#{count}-#{max_updated_at}"
    end
end
