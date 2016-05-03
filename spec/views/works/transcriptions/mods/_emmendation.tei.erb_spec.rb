require 'spec_helper'

describe ( '_emmendation' ) {
  subject { rendered }

  context ( 'normal mod' ) {
    let ( :mod ) {
      mock_model Alternate, subtype: 'emmendation', original_characters: 'hi', children: nil 
    }

    before {
      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_emmendation.tei' ), locals: { mod: mod }
    }

    it { should have_css 'del', text: 'hi' }
    it { should have_css 'del[type="emmendation"]' }
  }

  context ( 'mod with children' ) {
    let ( :inner_mod ) {
      stub_model Division, subtype: 'author'
    }
    let ( :mod ) {
      stub_model Alternate, subtype: 'emmendation', original_characters: 'hi', children: [ inner_mod ]
    }

    before {
      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_emmendation.tei' ), locals: { mod: mod }
    }

    it { should have_css 'del', text: 'hi' }
    it { should have_css 'del[type="emmendation"]' }
  }
}
