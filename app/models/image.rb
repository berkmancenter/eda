class Image < ActiveRecord::Base
  attr_accessible :credits, :url, :metadata
  serialize :metadata

  # a url to a static, web-sized version of this image 
  def preview_url
    if ( url == nil )
      return nil;
    end

    split_url = URI.split( url );
    url_id = split_url[ 5 ].slice( 1..-1 );
    return "sbs/#{url_id}.png";
  end
end
