module StaticPagesHelper
  def home_link( image, title, text, path )
    link_to raw( "#{image_tag( image, { alt: title })} <span class=\"home-link-title\">#{title}</span><p>#{text}</p>" ), path, { title: title }
  end

  def image_set_path_by_title( edition_prefix, image_title )
	e = Edition.find_by_work_number_prefix( edition_prefix )
	i = Image.find_by_title( image_title )

	is = e.image_set.leaves_containing( i ) unless is.nil?

	edition_image_set_path( e, is.first ) unless is.nil? || is.count == 0
  end
end
