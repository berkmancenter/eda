require 'spec_helper'

describe 'static pages requests' do
  subject { page }

  describe 'get /' do
    before { visit root_path }

    it {
      should have_title 'Emily Dickinson Archive'
    }

    it {
      should have_selector( 'body.static-pages.home' )
    }

    it { 
      should have_selector( 'a', { text: 'Home' } )
    }

    it {
      should have_css 'h1', text: I18n.t( 'works_search_h1' )
    }

    it {
      should have_css "form[action='#{search_works_path}']"
    }
  end

  describe 'get /about', :js => true do
    before { visit about_path }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )

      # full test of about-panel-menu links
      should have_selector( '.about-panel-menu a[href*="' + about_path + '"]' )
      should have_selector( '.about-panel-menu a[href*="' + faq_path + '"]' )
      should have_selector( '.about-panel-menu a[href*="' + team_path + '"]' )
      should have_selector( '.about-panel-menu a[href*="' + terms_path + '"]' )
      should have_selector( '.about-panel-menu a[href*="' + privacy_path + '"]' )
      should have_selector( '.about-panel-menu a[href*="' + contact_path + '"]' )
    }
  end

  describe 'get /faq' do
    before { visit faq_path }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )
    }
  end

  describe 'get /team' do
    before { visit team_path }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )
    }
  end

  describe 'get /terms' do
    before { visit terms_path }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )
    }
  end

  describe 'get /privacy' do
    before { visit privacy_path }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )
    }
  end

  describe 'get /contact' do
    before { visit contact_path }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )
    }
  end
end

