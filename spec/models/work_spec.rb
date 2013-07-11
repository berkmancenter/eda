require 'spec_helper'

describe( "Work model" ) {
  let ( :work ) { Work.first }

  subject { work }

  describe "#image_after" do
      context "work doesn't have an image with a greater position number" do
          it "returns nil" {}
      end

      context "work has an image with a greater position number" do
          it "returns the image with the next greatest position number" {}
      end
  end
  describe( "with valid data" ) {

    it {
      should be_valid
    }
  }

  describe( "with an edition" ) {
    describe( "the work's edition" ) {
      let ( :edition ) { work.edition }

      subject { edition }

      it { should be_valid }
      it { should respond_to( :works ) }
    }
  }
}
