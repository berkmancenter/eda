require "spec_helper"

describe ( "ImageGroupImage model" ) {
  let ( :igi ) { FactoryGirl.create( :igi_one ) }

  subject { igi }

  describe ( "with valid data" ) {
    it { should be_valid }
    it { should respond_to( :image ) }
  }
}
