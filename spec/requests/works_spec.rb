require 'spec_helper'

describe ( 'works requests' ) {
  subject { page }

  describe ( 'get /editions/:edition_id/works/:id' ) {

    describe ( 'with no stanzas' ) {
      let ( :work ) { Work.find_by_title( 'no_stanzas' ) }

      before { visit edition_work_url( { edition_id: work.edition_id, id: work.id } ) }

      it ( 'should render empty work and not throw exception' ) { 
        should have_selector( 'h2', { text: "#{work.number}#{work.variant} - #{work.title}" } );
      }
    }
  }
}


