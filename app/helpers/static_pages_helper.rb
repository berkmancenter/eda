module StaticPagesHelper
  def home_link( image, title, text, path )
    link_to raw( "#{image_tag( image, { alt: title })} <span class=\"home-link-title\">#{title}</span><p>#{text}</p>" ), path, { title: title }
  end
end
