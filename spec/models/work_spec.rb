require 'spec_helper'

describe( "Work model" ) {
  let ( :work ) { FactoryGirl.create( :work ) }

  subject { work }

  describe( "with valid data" ) {
    it {
      should be_valid
    }
  }
}
