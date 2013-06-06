require "spec_helper"

describe ( "ImageGroupImage model" ) {
  let ( :igi ) { ImageGroupImage.first }

  subject { igi }

  describe ( "with valid data" ) {
    it { should be_valid }
    it { should respond_to( :image_group ) }
    it { should respond_to( :image ) }
  }
}
