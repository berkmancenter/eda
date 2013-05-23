require 'spec_helper'

describe( "Edition model" ) {
  let ( :edition ) { nil }

  subject { edition }

  describe( "with valid data" ) {
    let ( :edition ) { FactoryGirl.create( :edition ) }

    it {
      should be_valid
    }
  }
}
