require 'spec_helper'

describe ( 'pages requests' ) {
  subject { page }

  describe ( 'get /editions/:edition_id/pages/:id' ) {

    describe ( 'with valid work, stanzas, image' ) {
      let ( :test_page ) { Page.find( 1 ) } # franklin, test work_one, image_one

      before { visit edition_page_url( { edition_id: test_page.edition_id, id: test_page.id } ) }

      it { 
        should have_selector( '#search-panel' );
        should have_selector( '#interactive-image-panel' );
        should have_selector( '#work-panel' );
      }
    }
  }
}

