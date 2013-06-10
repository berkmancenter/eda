require "spec_helper"

describe ( "Image model" ) {
  let ( :image ) { Image.first }

  subject { image }

  describe ( "with valid data" ) {
    it { should be_valid }
    it { should respond_to( :url ) }
    it { should respond_to( :preview_url ) }

    describe ( "has the correct preview_url" ) {
      it {
        split_url = URI.split( image.url );
        url_id = split_url[ 5 ].slice( 1..-1 );
        image.preview_url.should eq( "sbs/#{url_id}.png" );
      }
    }
  }
}
