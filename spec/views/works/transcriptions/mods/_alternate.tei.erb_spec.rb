require 'spec_helper'

describe ( '_alternate' ) {
  let ( :mod ) {
    mock_model Alternate, subtype: 'alternate', original_characters: 'hi', new_characters: 'ohai'
  }

  subject { rendered }

  context ( 'normal mod' ) {
    before {
      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_alternate.tei' ), locals: { mod: mod }
    }

    it { should have_css 'add', text: 'ohai' }
    it { should have_css 'add[type="alternate"]' }
    it { should have_css 'add[extent="hi"]' }
  }
}
