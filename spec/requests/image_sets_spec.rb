require 'spec_helper'

include ImagesHelper;

describe ( 'image_sets requests' ) {
  let ( :awake ) { 'Awake ye muses nine, sing me a strain divine' }
  let ( :sic ) { 'Sic transit gloria mundi' }
  let ( :wonder ) { 'On this wondrous sea' }

  let ( :awake_work ) { Work.find_by_title( awake ) }
  let ( :sic_work ) { Work.find_by_title( sic ) }
  let ( :wonder_work ) { Work.find_by_title( wonder ) }

  subject { page }

  describe ( 'get /editions/:edition_id/image_sets/:id' ) {


    context ( 'leaf/page view' ) {
      # require test:seed
      let ( :w ) { awake_work }

      # valid work, stanzas, image
      context 'with normal work', :js => true do
        before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

        it { 
          # header is no longer visible at top of page
          should_not have_selector 'h1', text: awake
        }

        it ( 'should have three main sections' ){ 
          should have_selector( '#search-panel' );

          should have_selector( '#interactive-image-panel' );

          should have_selector( '#work-panel' );
        }
      end

      context 'with valid next image' do
        let ( :image_set ) { w.image_set.children.first }

        before { visit edition_image_set_path( w.edition, image_set ) }

        it ( 'should have a valid next page' ) {
          next_image_set  = image_set.root.leaf_after( image_set )

          next_image_set.should_not == nil;

          page.should have_selector( "a[title='Next Page'][href*='#{edition_image_set_path( w.edition, next_image_set )}']" )
        }
      end

      context ( 'with work no stanzas, no image' ) {
        let ( :w ) { Work.find_by_title 'no_stanzas' }

        before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

        it {
          should have_title 'Emily Dickinson Archive'
        }

        it ( 'should have missing image' ) {
          should have_selector 'img[src*="missing_image.jpg"]'
        }

        it ( 'should have work title' ) {
          should have_text "#{w.number}#{w.variant}"
        }
      }

      describe 'search drawer', :js => true do
        before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

        it {
          should have_css '#search-panel'
          should_not have_css '#search-panel.collapsed'
        }

        describe ( 'click search drawer handle' ) {
          before {
            page.execute_script( %q[$('.left.drawer-handle').click( )] );
          }

          it ( 'should hide search panel' ) {
            should have_css '.view.minus-search-panel'
            should have_css '#search-panel.collapsed'
          }

          describe ( 'refresh with collapsed search drawer' ) {
            before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

            it ( 'should still hide search panel' ) {
              should have_css '.view.minus-search-panel'
              should have_css '#search-panel.collapsed'
            }
          }
        }
      end

      describe 'search panel', :js => true do
        before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

        context ( 'without search q' ) {
          it ( 'should have search works form' ) {
            should have_selector( '.search-works' );
            should have_selector( '.search-works form input[name="q"]' );
          }
        }

        context 'with search submit', :js => true do
          before {
            fill_in 'Search for:', with: 'awake'
            click_button 'Search'
          }

          it ( 'should have performed a search' ) {
            find( '.search-works-form input[name="q"]' ).value.should eq( 'awake' )

            should have_selector '.search-works-results'

            should have_css '.search-works-results a', count: 1
          }
        end
      end

      describe 'toggle browse panel', :js => true do
        before {
          visit "#{edition_image_set_path( w.edition, w.image_set.children.first )}"
          click_link 'Browse'
        }

        it {
          should have_css '.browse-works'
          current_url.should match 'search-panel=1'
        }

        describe ( 'toggle image drawer' ) {
          before {
            click_link I18n.t( :image_info )
          }

          it ( 'should not affect browse panel in url' ) {
            current_url.should match 'search-panel=1'
          }
        }
      end

      describe 'browse panel', :js => true do
        before {
          visit "#{edition_image_set_path( w.edition, w.image_set.children.first )}#search-panel=1"
        }

        context ( 'default view' ) {
          it { 
            should have_css '.browse-works'
            should have_css '.browse-works .alphabet-list'
            should have_css '.alphabet-list a', text: 'O'
            should have_css '.browse-works .alphabet-results'
            should have_css '.browse-works .alphabet-results.browse-works-results'
          }
        }

        context ( 'click browse letter for work sharing image' ) {
          before {
            click_link 'S'
          }

          it {
            should have_css '.browse-works-results a', text: sic
          }

          it ( 'should have work-result-items' ) {
            should_not have_css '.browse-works-results table'
            should have_css '.browse-works-results ul.work-list'
            should have_css 'li.work-list-item', count: 1
          }

          context ( 'click result' ) {
            before {
              #click_link sic
            }

            it ( 'should have header for next work' ) {
              # todo: work with first image sharing this work's last image
              pending 'should have_css h1, text: sic'
              should have_css 'h1', text: sic
            }
          }
        }

        context ( 'click browse letter for disparate work' ) {
          before {
            click_link 'O'
          }

          it {
            should have_css '.browse-works-results a', text: wonder
          }

          context ( 'click result' ) {
            before {
              click_link wonder
            }

            it {
              should have_css '.work-transcription h3', text: wonder
            }
          }
        }

      end

      describe 'interactive image panel', :js => true do
        let ( :image_set ) { w.image_set.children.first }

        before { visit edition_image_set_path( w.edition, image_set ) }

        it ( 'should have header' ) {
          should have_css '#interactive-image-panel h1', text: image_set.image.metadata['Label']
        }
        
      end

      describe 'image drawer', :js => true do
        before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

        it ( 'should have one' ) {
          should have_css '#interactive-image-panel .image-drawer'
        }

        it ( 'should be open by default (via image-panel parent)' ) {
          should_not have_css '#interactive-image-panel.collapsed'
        }

        it ( 'should only have image info visible by default' ) {
          should_not have_css 'a[data-drawer="image-set-info"].hidden'
          should_not have_css '#image-set-info.hidden'

          should have_css 'a[data-drawer="set-notes"].hidden'
          should have_css '#set-notes.hidden', visible: false
        }

        context ( 'click text panel' ) {
          before {
            page.execute_script( %q[$('.right.drawer-handle').click( )] );
          }

          it ( 'should not affect the bottom drawer' ) {
            should_not have_css '#interactive-image-panel.collapsed'
          }
        }

        context ( 'click image info tab' ) {
          before {
            click_link I18n.t( :image_info )
          }

          it {
            should have_css '#interactive-image-panel.collapsed'
          }

          context ( 'click image info tab again' ) {
            before {
              click_link I18n.t( :image_info )
            }

            it {
              should_not have_css '#interactive-image-panel.collapsed'
            }
          }

          context ( 'click notes tab' ) {
            before {
              click_link I18n.t( :my_notes )
            }

            it {
              should_not have_css '#interactive-image-panel.collapsed'
            }

            it ( 'should switch to notes tab' ) {
              should have_css '#image-set-info.hidden', visible: false

              should_not have_css '#set-notes.hidden'
            }
          }
        }

        context ( 'click notes tab' ) {
          before {
            click_link I18n.t( :my_notes )
          }

          it {
            should_not have_css '#interactive-image-panel.collapsed'
          }

          it ( 'should switch to notes tab' ) {
            should have_css 'a[data-drawer="image-set-info"].hidden'
            should have_css '#image-set-info.hidden', visible: false

            should_not have_css 'a[data-drawer="set-notes"].hidden'
            should_not have_css '#set-notes.hidden'
          }

        }

      end

      describe 'text drawer', :js => true do
        before {
          visit edition_image_set_path( w.edition, w.image_set.children.first )
        }

        it ( 'should default to closed #5754' ) {
          should have_css '.view.minus-work-panel'
          should have_css '#work-panel.collapsed'
        }

        describe ( 'click text drawer handle' ) {
          before {
            page.execute_script( %q[$('.right.drawer-handle').click( )] );
          }

          it ( 'should show work panel' ) {
            should_not have_css '.view.minus-work-panel'
            should_not have_css '#work-panel.collapsed'
          }

          describe ( 'refresh with collapsed text drawer' ) {
            before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

            it ( 'should still hide work panel' ) {
              should_not have_css '.view.minus-work-panel'
              should_not have_css '#work-panel.collapsed'
            }
          }

        }
      end

      context 'text drawer with panel selection', :js => true do
        before {
          visit "#{edition_image_set_path( w.edition, w.image_set.children.first )}#work-panel=0"
        }

        it ( 'should default to open' ) {
          # user needs to see the 'selected' panel in the drawer
          should_not have_css '.view.minus-work-panel'
          should_not have_css '#work-panel.collapsed'
        }
      end

      describe 'lexicon panel', :js => true do
        before {
          visit "#{edition_image_set_path( w.edition, w.image_set.children.first )}#work-panel=1"
        }

        it {
          should have_css '.browse-lexicon'
          should have_css '.alphabet-list'
          should have_css '.alphabet-list a', text: 'A'
          should have_css '.alphabet-results'
          should have_css '.alphabet-results.lexicon-results'
          should_not have_css '.lexicon-results a'
          should have_css '.lexicon-word'
          should_not have_css '.lexicon-word section.word'
        }
      end

      describe 'click lexicon letter', :js => true do
        before {
          visit "#{edition_image_set_path( w.edition, w.image_set.children.first )}#work-panel=1"
        }

        it {
          click_link 'A'
          should have_css '.lexicon-results a'
        }
      end

      describe 'click lexicon letter', :js => true do
        before {
          visit "#{edition_image_set_path( w.edition, w.image_set.children.first )}#work-panel=1"
        }

        it {
          click_link 'A'
          click_link 'awake'
          #should have_css '.lexicon-word section.word'
          find( '.simplemodal-data' ).visible?.should be_true
        }
      end
    }

    context ( 'non-leaf/sbs view' ) {
      describe ( 'get /editions/:edition_id/image_sets/:id' ) {

        describe ( 'with valid image set having multiple images' ) {
          let ( :w ) { Work.find_by_title( awake ) }

          before { visit edition_image_set_path( w.edition, w.image_set ) }

          it { 
            should have_title w.image_set.name
          }

          it ( 'should have img tags for all ImageSet images' ) {
            should have_css( "img[src*='#{preview_url( w.image_set.children[0].image )}']" );
            should have_css( "img[src*='#{preview_url( w.image_set.children[1].image )}']", visible: false );
            should have_css( "img[src*='#{preview_url( w.image_set.children[2].image )}']", visible: false );
          }
        }
      }
    }
  }
}


