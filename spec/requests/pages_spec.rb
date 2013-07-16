require 'spec_helper'

describe ( 'pages requests' ) {
  subject { page }

  describe ( 'get /editions/:edition_id/pages/:id' ) {
    # require test:seed
    let ( :test_page ) { Page.find( 1 ) } # franklin, test work_f1a, image_one

    describe ( 'with valid work, stanzas, image' ) {
      before { visit edition_page_path( test_page.edition, test_page ) }

      it ( 'should have three main sections' ){ 
        should have_selector( '#search-panel' );

        should have_selector( '#interactive-image-panel' );

        should have_selector( '#work-panel' );
      }

      it ( 'should have a valid next page' ) {
        next_page = test_page.next;
        next_page.should_not == nil;

        page.should have_selector( 'a[title="Next Page"][href="' + edition_page_url( { edition_id: next_page.edition_id, id: next_page.id } ) + '"]' );
      }
    }

    describe ( 'search panel' ) {
      describe ( 'without search q' ) {
        before { visit edition_page_path( test_page.edition, test_page ) }

        it ( 'should have search works form' ) {
          should have_selector( '.search-works' );
          should have_selector( '.search-works form input[name="q"]' );
        }
      }

      describe ( 'with search submit' ) {
        before {
          visit edition_page_path( test_page.edition, test_page );
          fill_in( 'Search for:', { with: 'awake' } );
          click_button( 'Search' );
        }

        it ( 'should have performed a search' ) {
          should have_selector( '.search-works form input[name="q"][value="awake"]' );

          should have_selector( '.search-works-results' );

          should have_css( '.search-works-results a', { count: 1 } );
        }

      }
    }

    describe ( 'browse panel' ) {
      before { visit edition_page_path( test_page.edition, test_page ) }

      it { 
        should have_selector( '.browse-works' );
      }
    }

  }
}

