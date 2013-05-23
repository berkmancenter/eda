require 'spec_helper'

describe( "Edition model" ) {
  let ( :edition ) { FactoryGirl.create( :edition ) }

  subject { edition }

  describe( "with valid data" ) {
    it {
      should be_valid
    }
  }
}
