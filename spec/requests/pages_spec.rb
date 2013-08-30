#require 'spec_helper'
#
#describe 'pages requests' do
#  subject { page }
#
#  describe ( 'get /editions/:edition_id/pages/:id' ) {
#    # require test:seed
#    let ( :test_page ) { Page.find( 1 ) } # franklin, test work_f1a, image_one
#
#    context 'with valid work, stanzas, image', :js => true do
#      before { visit edition_page_path( test_page.edition, test_page ) }
#
#      it ( 'should have three main sections' ){ 
#        should have_selector( '#search-panel' );
#
#        should have_selector( '#interactive-image-panel' );
#
#        should have_selector( '#work-panel' );
#      }
#    end
#
#    context 'with valid next image' do
#      before { visit edition_page_path( test_page.edition, test_page ) }
#
#      it ( 'should have a valid next page' ) {
#        next_page = test_page.next;
#        next_page.should_not == nil;
#
#        page.should have_selector( 'a[title="Next Page"][href*="' + edition_page_path( { edition_id: next_page.edition_id, id: next_page.id } ) + '"]' );
#      }
#    end
#
#    context 'with work no stanzas, no image' do
#      let ( :w ) { Work.find_by_title 'no_stanzas' }
#
#      before {
#        p = Page.with_imageless_work w
#        visit edition_page_path p.edition, p
#      }
#
#      it do
#        should have_title 'Emily Dickinson Archive'
#      end
#
#      it 'should have missing image' do
#        should have_selector 'img[src*="missing_image.jpg"]'
#      end
#
#      it 'should have work title' do
#        should have_text "#{w.number}#{w.variant}"
#      end
#    end
#
#    describe ( 'search panel' ) do
#      context 'without search q' do
#        before { visit edition_page_path( test_page.edition, test_page ) }
#
#        it ( 'should have search works form' ) {
#          should have_selector( '.search-works' );
#          should have_selector( '.search-works form input[name="q"]' );
#        }
#      end
#
#      context 'with search submit' do
#        before {
#          visit edition_page_path( test_page.edition, test_page );
#          fill_in( 'Search for:', { with: 'awake' } );
#          click_button( 'Search' );
#        }
#
#        it ( 'should have performed a search' ) {
#          should have_selector( '.search-works form input[name="q"][value="awake"]' );
#
#          should have_selector( '.search-works-results' );
#
#          should have_css( '.search-works-results a', { count: 1 } );
#        }
#      end
#    end
#
#    describe ( 'browse panel' ) {
#      before { visit edition_page_path( test_page.edition, test_page ) }
#
#      it { 
#        should have_selector( '.browse-works' );
#      }
#    }
#
#  }
#end
#
