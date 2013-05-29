module ApplicationHelper
  def body_class( params )
    controller_name = params[:controller].clone
    if controller_name.index '_'
      controller_name[ '_' ] = '-'
    end
    "#{controller_name} #{params[:action]}"
  end
end
