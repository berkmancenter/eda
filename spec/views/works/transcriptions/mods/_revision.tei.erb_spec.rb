require 'spec_helper'

describe ( '_revision' ) {
  subject { rendered }

  context ( 'normal mod' ) {
    let ( :mod ) {
      mock_model Alternate, subtype: 'revision', original_characters: 'hi', new_characters: 'ohai', children: nil 
    }

    before {
      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_revision.tei' ), locals: { mod: mod }
    }

    it { should have_css 'app' }
    it { should have_css 'app[type="revision"]' }
    it { should have_css 'app lem', text: 'hi' }
    it { should have_css 'app rdg', text: 'ohai' }
  }
}
