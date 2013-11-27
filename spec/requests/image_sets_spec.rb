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

      context ( 'with invalid image' ) {
        let ( :image_set ) { ImageSet.find( 23 ) }

        before {
          visit edition_image_set_path( w.edition, image_set )
        }

        it {
          # just show missing_image instead of raising 404
          page.status_code.should eq( 200 )
        }
      }

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

        describe ( 'search options toggle' ) {
          it {
            should have_css 'a.search-works-options-toggle'
            should have_css 'div.search-works-options', visible: false
          }

          context ( 'default' ) {
            it {
              should_not have_css 'a.search-works-options-toggle.open'
              should_not have_css 'div.search-works-options.open'
            }
          }

          context ( 'with open options' ) {
            before {
              click_link 'Search options'
            }
  
            it {
              should have_css 'a.search-works-options-toggle.open'
              should have_css 'div.search-works-options.open'
            }

            context ( 'with refresh after open' ) {
              before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

              it {
                should have_css 'a.search-works-options-toggle.open'
                should have_css 'div.search-works-options.open'
              }
            }

            context ( 'with re-closed options' ) {
              before {
                click_link 'Search options'
              }
    
              it {
                should_not have_css 'a.search-works-options-toggle.open'
                should_not have_css 'div.search-works-options.open'
              }

              context ( 'with refresh after re-closed' ) {
                before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

                it {
                  should_not have_css 'a.search-works-options-toggle.open'
                  should_not have_css 'div.search-works-options.open'
                }
              }
            }
          }
        }

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

      describe 'lexicon panel', :js => true do
        before {
          visit "#{edition_image_set_path( w.edition, w.image_set.children.first )}#search-panel=2"
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
          visit "#{edition_image_set_path( w.edition, w.image_set.children.first )}#search-panel=2"
        }

        it {
          click_link 'A'
          should have_css '.lexicon-results a'
        }
      end

      describe 'click lexicon letter', :js => true do
        before {
          visit "#{edition_image_set_path( w.edition, w.image_set.children.first )}#search-panel=2"
        }

        it {
          click_link 'A'
          click_link 'awake'
          #should have_css '.lexicon-word section.word'
          find( '.simplemodal-data' ).visible?.should be_true
        }
      end

      describe 'interactive image panel', :js => true do
        let ( :image_set ) { w.image_set.children.first }

        before { visit edition_image_set_path( w.edition, image_set ) }

        it ( 'should have header' ) {
          should have_css '#interactive-image-panel h1', text: 'p. 2, Your - Riches - taught me - poverty! , L258, J299, Fr418'
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

      context 'user content', :js => true do
        before {
          visit "#{edition_image_set_path( w.edition, w.image_set.children.first )}#work-panel=0"
        }

        it ( 'should sign in' ) {
          click_link 'Sign In'
          should have_css 'form.new_user'

          test_user = FactoryGirl.attributes_for :test_user
          fill_in 'Email', with: test_user[:email]
          fill_in 'Password', with: test_user[:password]
          click_button 'Sign in'
          should have_css 'a', text: 'My Account'
        }

        context ( 'with sign in' ) {
          before {
            click_link 'Sign In'
            test_user = FactoryGirl.attributes_for :test_user
            fill_in 'Email', with: test_user[:email]
            fill_in 'Password', with: test_user[:password]
            click_button 'Sign in'
          }

          it {
            should have_css 'a', text: 'My Account'
          }

          describe ( 'edit transcription' ) {
            before {
              click_link 'Edit transcription'
            }

            it { 
              should have_css 'h2', text: 'Create New Edition'
            }

            describe ( 'create user edition from blank edition' ) {
              let ( :user_edition ) { FactoryGirl.attributes_for :user_edition }
              let ( :new_work_text ) { 'User edition transcription update which can be searched' }

              before {
                select '[None]', from: 'edition_parent_id'
                fill_in 'Name', with: user_edition[:name]
                fill_in 'Short name', with: user_edition[:short_name]
                fill_in 'Author', with: user_edition[:author]
                fill_in 'Description', with: user_edition[:description]
                fill_in 'Work number prefix', with: user_edition[:work_number_prefix]
                click_button 'Create Edition'
              }

              it {
                should have_css 'form.work'
              }

              describe ( 'update transcription' ) {
                before {
                  fill_in 'Text', with: new_work_text
                  click_button 'Update Work'
                }

                it {
                  should_not have_css 'form.work'

                  should have_css 'h3', "#{user_edition[:work_number_prefix]}#{w.number}#{w.variant}"
                  should have_css '.line', text: new_work_text
                }

                describe ( 'search for updated transcription' ) {
                  before {
                    fill_in 'Search for:', with: 'searched'
                    click_button 'Search'
                  }

                  it ( 'should have found edited work' ) {
                    should have_css '.search-works-results a span.work-number', text: "#{user_edition[:work_number_prefix]}#{w.number}"
                  }
                }
              }
            }
          }

          describe ( 'edit notes' ) {
            before {
              click_link 'My Notes'
            }

            it {
              should have_css '#set-notes .notes-container'
            }

            it {
              should have_css 'input[name="note[note]"]'
            }

            it {
              find( '#note_note' ).value.should eq( '' )
            }

            it {
              Note.count.should eq( 0 )
            }

            describe ( 'add new note' ) {
              before {
                fill_in 'note_note', with: 'a test note'
                click_button 'Save'
              }

              it {
                should_not have_css '.note-save-result', text: 'Saved'
              }

              it {
                should have_css '.notes-container li.note', text: 'a test note'
              }

              describe ( 'delete note' ) {
                before {
                  within( :css, 'li.note' ) do
                    click_link 'x'
                  end
                }

                it {
                  snap
                  should_not have_css '.notes-container li.note'
                }
              }

              describe ( 'view in My Notes' ) {
                before {
                  visit my_notes_path
                }

                it {
                  should have_css 'li p', text: 'a test note'
                }

                it {
                  should have_css '.view li', count: 1
                }
              }

              context ( 'two saves without leaving page' ) {
                before {
                  fill_in 'note_note', with: 'editing in same context'
                  click_button 'Save'
                }

                it {
                  should have_css '.notes-container li.note', count: 2
                }

                describe ( 'check out My Notes' ) {
                  before {
                    visit my_notes_path
                  }

                  it {
                    should have_css '.view li', count: 2
                  }
                }
              }
            }
          }
        }
      end

      context ( 'with nonexistant id' ) {
        before {
          visit edition_image_set_path( w.edition, 31337 )
        }

        it {
          page.status_code.should eq( 404 )
        }
      }
    }

    context 'reading view', :js => true do
      describe ( 'get /editions/:edition_id/image_sets/:id' ) {

        describe ( 'with valid image set having multiple images' ) {
          let ( :w ) { Work.find_by_title( awake ) }

          before { visit edition_image_set_path( w.edition, w.image_set ) }

          it { 
            should have_title w.image_set.name
          }

          it ( 'should have img tags for all ImageSet images' ) {
            should have_css "img[src*='#{ w.image_set.children[0].image.url }']"
            should have_css "img[src*='#{ w.image_set.children[1].image.url }']", visible: false
            should have_css "img[src*='#{ w.image_set.children[2].image.url }']", visible: false
          }
        }
      }
    end
  }
}


