require 'spec_helper'

describe ( 'image_sets/_notes_list' ) {
  let ( :sett ) { mock_model( ImageSet ) }

  subject { rendered }

  context ( 'normal notes' ) {
    let ( :notes ) {
      [ mock_model( Note ), mock_model( Note ) ]
    }

    before {
      render partial: 'image_sets/notes_list', locals: { sett: sett, notes: notes }
    }

    it {
      should have_css 'ul.notes'
    }

    it {
      should have_css 'ul li.note', count: 2
    }

    it {
      should have_css 'li span.note-text'
    }

    it {
      should have_css 'li a.delete-note', text: 'x'
    }
  }

  context ( 'nil notes' ) {
    let ( :notes ) { nil }

    before {
      render partial: 'image_sets/notes_list', locals: { sett: sett, notes: notes }
    }

    it { 
      should_not have_css 'ul.notes'
    }
  }
}
