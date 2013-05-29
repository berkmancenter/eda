require 'spec_helper'

describe( 'editions requests' ) {
  subject { page }

  describe( 'get /editions' ) {
    before { visit editions_url }

    it { 
      # generic test to make sure non-static pages are at least compiling
      should have_selector( 'h2', { text: 'Editions' } );
    }
  }
}
