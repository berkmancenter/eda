require 'spec_helper'

describe 'static pages requests' do
  subject { page }

  describe 'get /' do
    before { visit root_url }

    it {
      should have_selector( 'title', { text: 'Emily Dickinson Archive' } )
    }

    it {
      should have_selector( 'body.static-pages.home' )
    }

    it { 
      should have_selector( 'a', { text: 'Home' } )
    }

  end

  describe 'get /about' do
    before { visit about_url }

    it {
      should have_selector( 'title', { text: 'About Emily Dickinson Archive' } )
    }

    it {
      should have_selector( '.about-panel-menu' )
    }

  end
end

