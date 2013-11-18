require 'spec_helper'

describe 'works requests', :js => true do
  subject { page }

  describe ( 'get /editions/:edition_id/works' ) {
    before { visit edition_works_path Edition.find( 2 ) }

    it ( 'should work' ) {
      should have_title 'Emily Dickinson Archive'
    }

    it ( 'should not have Edition column' ) {
      should_not have_css 'td', text: 'Edition'
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

