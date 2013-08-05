module StaticPagesHelper
  def home_link( image, title, path )
    link_to raw( "#{image_tag( image, { alt: title })} <span class=\"home-link-title\">#{title}</span>" ), path, { title: title }
  end
end
