require 'spec_helper'

describe ( '_author_division' ) {
  let ( :mod ) {
    mock_model Division, subtype: 'author'
  }

  subject { rendered }

  context ( 'normal mod' ) {
    before {
      render file: Rails.root.join( 'app\views\works\transcriptions\mods\_author_division.tei' ), locals: { mod: mod }
    }

    it { should have_css 'app' }
    it { should have_css 'app[type="division"]' }
    it { should have_css 'app lem' }
    it { should have_css 'app lem lb' }
    it { should have_css 'app lem lb[rend="none"]' }
  }
}
