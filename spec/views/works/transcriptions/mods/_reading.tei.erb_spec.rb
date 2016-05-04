require 'spec_helper'

describe ( '_reading' ) {
  let ( :mod ) {
    mock_model Alternate, subtype: 'reading', new_characters: 'ohai'
  }

  subject { rendered }

  context ( 'normal mod' ) {
    before {
      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_reading.tei' ), locals: { mod: mod }
    }

    it { should have_css 'add', text: 'ohai' }
    it { should have_css 'add[type="reading"]' }
    it { should_not have_css 'add[extent]' }
  }
}
