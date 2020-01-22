module FileCacheHelper
  def with_file_cache
    regular_cache = ActionController::Base.cache_store
    ActionController::Base.cache_store = EDAFileCache
    yield
    ActionController::Base.cache_store = regular_cache
  end
end
