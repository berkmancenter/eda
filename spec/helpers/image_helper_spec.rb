require 'spec_helper';

include ImagesHelper;

describe ( 'ImageHelper module' ) {
  describe ( 'preview_url' ) {
    it ( 'should return url to preview image' ) {
      image = Image.new( { url: 'ms_am_1118_10_10_0002' } );
      previewUrl = preview_url( image )
      previewUrl.should eq( "#{Eda::Application.config.emily['web_image_directory']}/#{image.url}.jpg" );
    }
  }
}
