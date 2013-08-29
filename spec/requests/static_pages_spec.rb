require 'spec_helper'

describe 'static pages requests' do
  subject { page }

  describe 'get /' do
    before { visit root_url }

    it {
      should have_title 'Emily Dickinson Archive'
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
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )

      # full test of about-panel-menu links
      should have_selector( '.about-panel-menu a[href="' + about_url + '"]' )
      should have_selector( '.about-panel-menu a[href="' + faq_url + '"]' )
      should have_selector( '.about-panel-menu a[href="' + team_url + '"]' )
      should have_selector( '.about-panel-menu a[href="' + terms_url + '"]' )
      should have_selector( '.about-panel-menu a[href="' + privacy_url + '"]' )
      should have_selector( '.about-panel-menu a[href="' + contact_url + '"]' )
    }
  end

  describe 'get /faq' do
    before { visit faq_url }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )
    }
  end

  describe 'get /team' do
    before { visit team_url }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )
    }
  end

  describe 'get /terms' do
    before { visit terms_url }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )
    }
  end

  describe 'get /privacy' do
    before { visit privacy_url }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )
    }
  end

  describe 'get /contact' do
    before { visit contact_url }

    it {
      should have_title 'About Emily Dickinson Archive'
    }

    it {
      should have_selector( '.about-panel-menu' )
    }
  end
end

