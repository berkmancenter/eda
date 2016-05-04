require 'spec_helper'

describe ( '_page_or_column_division' ) {
  subject { rendered }

  context ( 'page division' ) {
    let ( :mod ) {
      mock_model Division, subtype: 'page'
    }

    before {
      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_page_or_column_division.tei' ), locals: { mod: mod }
    }

    it { should have_css 'app' }
    it { should have_css 'app[type="division"]' }
    it { should have_css 'app lem' }
    it { should have_css 'app lem pb' }
  }

  context ( 'column division' ) {
    let ( :mod ) {
      mock_model Division, subtype: 'column'
    }

    before {
      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_page_or_column_division.tei' ), locals: { mod: mod }
    }

    it { should have_css 'app' }
    it { should have_css 'app[type="division"]' }
    it { should have_css 'app lem' }
    it { should have_css 'app lem pb' }
  }
}
