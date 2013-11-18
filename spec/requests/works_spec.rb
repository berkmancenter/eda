require 'spec_helper'

describe 'works requests', :js => true do
  subject { page }

  describe ( 'get /works' ) {
    before { visit works_path }

    it ( 'should work' ) {
      should have_title 'Works'
    }

    it ( 'should have Edition column' ) {
      should have_css 'th', text: 'Edition'
    }

    context ( 'with search within' ) {
      before {
        fill_in 'Search within these results:', with: 'sing'
      }

      it {
        should have_css 'tbody tr', count: 2
      }

      describe ( 'click first link' ) {
        before {
          click_link 'Awake ye muses nine, sing me a strain divine'
        }

        it {
          should have_title 'Manuscript View'
        }

        describe ( 'go back' ) {
          before {
            visit works_path
          }

          it {
            should have_title 'Works'
            should have_css '.dataTables_filter'
          }

          it {
            filter = page.evaluate_script "$('.dataTables_filter input').val()"
            puts filter
            filter.should eq( 'sing' )
          }

        }
      }
    }
  }

  describe ( 'get /collections' ) {
    before { visit collections_path }

    it ( 'should work' ) {
      should have_title 'Collections'
    }
  }

  describe ( 'get /editions/:edition_id/works' ) {
    before { visit edition_works_path Edition.find( 2 ) }

    it ( 'should work' ) {
      should have_title 'Emily Dickinson Archive'
    }

    it ( 'should not have Edition column' ) {
      should_not have_css 'th', text: 'Edition'
    }

  }

  describe ( 'get /editions/:edition_id/works/:id' ) {
    context 'with no stanzas' do
      let ( :work ) { Work.find_by_title 'no_stanzas' }

      before { visit edition_work_path( work.edition, work ) }

      it ( 'should render empty work and not throw exception' ) { 
        should have_title 'Emily Dickinson Archive'
      }
    end
  }
end

