require 'spec_helper'

describe( "Edition model" ) {
  subject { edition }

  describe( "with valid data" ) {
    let ( :edition ) { Edition.find_by_work_number_prefix( 'J' ) }

    it {
      should be_valid
    }
  }
}
