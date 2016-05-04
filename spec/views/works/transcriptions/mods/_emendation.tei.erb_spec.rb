require 'spec_helper'

describe ( '_emendation' ) {
  subject { rendered }

  context ( 'normal mod' ) {
    let ( :mod ) {
      mock_model Alternate, subtype: 'emendation', original_characters: 'hi', new_characters: 'ohai', children: nil 
    }

    before {
      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_emendation.tei' ), locals: { mod: mod }
    }

    it { should have_css 'app' }
    it { should have_css 'app[type="emendation"]' }
    it { should have_css 'app lem', text: 'hi' }
    it { should have_css 'app rdg', text: 'ohai' }
  }

#  context ( 'mod with children' ) {
#    let ( :inner_mod ) {
#      stub_model Division, subtype: 'author'
#    }
#    let ( :mod ) {
#      stub_model Alternate, subtype: 'emendation', original_characters: 'hi', children: [ inner_mod ]
#    }
#
#    before {
#      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_emendation.tei' ), locals: { mod: mod }
#    }
#
#    it { should have_css 'del', text: 'hi' }
#    it { should have_css 'del[type="emendation"]' }
#  }
}
