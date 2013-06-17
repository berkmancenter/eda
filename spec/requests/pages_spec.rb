require 'spec_helper'

describe ( 'pages requests' ) {
  subject { page }

  describe ( 'get /editions/:edition_id/pages/:id' ) {

    describe ( 'with valid work, stanzas, image' ) {
      let ( :test_page ) { Page.find( 1 ) } # franklin, test work_f1a, image_one

      before { visit edition_page_url( { edition_id: test_page.edition_id, id: test_page.id } ) }

      it { 
        should have_selector( '#search-panel' );

        should have_selector( '#interactive-image-panel' );

        next_page = test_page.next;
        should have_selector( 'a[title="Next Page"][href="' + edition_page_url( { edition_id: next_page.edition_id, id: next_page.id } ) + '"]' );

        should have_selector( '#work-panel' );
      }
    }
  }
}

