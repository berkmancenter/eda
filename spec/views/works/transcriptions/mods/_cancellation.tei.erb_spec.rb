require 'spec_helper'

describe ( '_cancellation' ) {
  subject { rendered }

  context ( 'normal mod' ) {
    let ( :mod ) {
      mock_model Alternate, subtype: 'cancellation', original_characters: 'hi', children: nil 
    }

    before {
      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_cancellation.tei' ), locals: { mod: mod }
    }

    it { should have_css 'del', text: 'hi' }
    it { should have_css 'del[type="canceled"]' }
    it { should have_css 'del[extent="hi"]' }
  }

#  context ( 'mod with children' ) {
#    let ( :inner_mod ) {
#      stub_model Division, subtype: 'author', start_address: 0
#    }
#    let ( :mod ) {
#      m = stub_model Alternate, subtype: 'cancellation', original_characters: '', new_characters: ''
#      m.children << inner_mod
#      m
#    }
#
#    before {
#      render file: Rails.root.join( 'app/views/works/transcriptions/mods/_cancellation.tei' ), locals: { mod: mod }
#    }
#
#    it { should have_css 'del' }
#    it { should have_css 'del[type="canceled"]' }
#
#    describe ( 'del_app' ) {
#    it {
#      puts rendered
#      should have_css 'del app'
#    }
#    }
#  }
}
