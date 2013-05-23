require 'spec_helper'

describe 'static pages requests' do
  subject { page }

  describe 'get /' do
    before { visit root_url }

    it {
      should have_selector( 'title', { text: 'Emily Dickinson Archive' } )
    }

  end

  describe 'get /about' do
    before { visit about_url }

    it {
      should have_selector( 'title', { text: 'About Emily Dickinson Archive' } )
    }

    it {
      should have_selector( 'h1', { text: 'About Emily Dickinson Archive' } )
    }

  end
end

