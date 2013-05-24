require 'spec_helper'

describe( "Work model" ) {
  let ( :work ) { FactoryGirl.create( :work_one ) }

  subject { work }

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
