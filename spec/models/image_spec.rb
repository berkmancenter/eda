require "spec_helper"

describe ( "Image model" ) {
  let ( :image ) { FactoryGirl.create( :image_one ) }

  subject { image }

  describe ( "with valid data" ) {
    it { should be_valid }
  }
}
