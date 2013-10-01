require 'spec_helper'

describe( "Work model" ) {
  let ( :work ) { Work.first }

  subject { work }

  describe( "with valid data" ) {
    it {
      should be_valid
    }
  }

  describe 'has_image?' do
    it { pending 'returns true if work has image' }
  end

  describe( "with an edition" ) {
    describe( "the work's edition" ) {
      it {
        work.edition.should_not eq( nil )
      }
    }
  }

  describe ( 'find_by_edition_and_image_set' ) {
    it {
      pending 'should return all works in the given image_set'
    }
  }
}
