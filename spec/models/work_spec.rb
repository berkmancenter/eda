require 'spec_helper'

describe( "Work model" ) {
  let ( :work ) { nil } 

  subject { work }

  describe( "with valid data" ) {
    let ( :work ) { FactoryGirl.create( :work ) }

    it {
      should be_valid
    }
  }

  describe( "with an edition" ) {
    let ( :work ) { FactoryGirl.create( :work_with_edition ) }

    it {
      should be_valid
    }

    describe( "the work's edition" ) {
      let ( :edition ) { work.edition }

      subject { edition }

      it { should be_valid }
      it { should respond_to( :works ) }
    }
  }
}
