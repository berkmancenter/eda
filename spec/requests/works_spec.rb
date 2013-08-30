require 'spec_helper'

describe ( 'works requests' ) {
  subject { page }

  describe 'get /editions/:edition_id/works' do
    before { visit edition_works_path Edition.find( 2 ) }

    it 'should work' do
      should have_title 'Emily Dickinson Archive'
    end

  end

  describe 'get /editions/:edition_id/works/:id' do
    context 'with no stanzas' do
      let ( :work ) { Work.find_by_title 'no_stanzas' }

      before { visit edition_work_path( work.edition, work ) }

      it ( 'should render empty work and not throw exception' ) { 
        # redirect to edition_image_set_path
        should have_selector( 'h3', text: "#{work.number}#{work.variant} - #{work.title}" );
      }
    end
  end
}


