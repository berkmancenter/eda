EDAFileCache = ActiveSupport::Cache::FileStore.new(Rails.configuration.eda_file_cache)
ActionController::Base.cache_store = EDAFileCache
