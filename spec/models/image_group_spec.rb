require "spec_helper"

describe ( "ImageGroup model" ) {
  describe ( "type = Collection" ) {
    let ( :igrp ) { ImageGroup.find_by_name( 'Harvard Collection' ) }

    subject { igrp }

    describe ( "with valid data" ) {
      it { should be_valid }
      it { should respond_to( :image_group_images ) }
      it { should respond_to( :images ) }
      it { should respond_to( :work ) }

      it { 
        igrp.type.should eq( 'Collection' );
      }

      it { 
        igrp.parent.should eq( nil );
      }

    }
  }

  describe ( "with images" ) {
    it {
      igrp_one = ImageGroup.find_by_name( 'Awake ye muses nine, sing me a strain divine' );

      # tied to specific test data
      igrp_one.images.count.should eq 3;
    }
  }
}
