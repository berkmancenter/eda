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
    }
  }
}
