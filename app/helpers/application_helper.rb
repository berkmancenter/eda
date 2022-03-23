module ApplicationHelper
  def body_class( params )
    controller_name = params[:controller].dup
    if controller_name.index '_'
      controller_name[ '_' ] = '-'
    end
    "#{controller_name} #{params[:action]}"
  end

  def link_selected?(link_key)
      link_condition_map = {
          :home_link => ( params[ :action ] == 'home' ),
          :manuscript_link => ( params[ :controller ] == 'works' && params[ :action ] == 'index' ),
          :lexicon_link => ( params[:controller] == 'words' ),
          :about_link => ( params[ :action ] == 'about' || params[ :action ] == 'faq' || params[ :action ] == 'team' || params[ :action ] == 'terms' || params[ :action ] == 'privacy' || params[ :action ] == 'contact' )
      }
      if link_condition_map.include?(link_key)
          return link_condition_map[link_key]
      else
          return false
      end
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def cache_key_for_multiple(objects)
        count          = objects.count
        max_updated_at = objects.maximum(:updated_at).try(:utc).try(:to_s, :number)
        "#{objects.first.class.name.underscore.pluralize}/many-#{objects.first.id}-#{objects.last.id}-#{count}-#{max_updated_at}"
  end
end
