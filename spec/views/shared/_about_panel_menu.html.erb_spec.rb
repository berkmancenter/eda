require 'spec_helper'

describe ( 'shared/_about_panel_menu' ) {
  subject { rendered }

  context ( 'no selection' ) {
    before {
      render partial: 'shared/about_panel_menu', locals: { 
        params: { }
      }
    }

    it {
      should have_css 'ul.about-panel-menu'
      should have_css 'ul.panel-menu'
    }

    it {
      should have_css "a[href*='#{about_path}']", text: 'Overview'
      should have_css "a[href*='#{faq_path}']", text: 'FAQ'
      should have_css "a[href*='#{resources_path}']", text: 'Resources'
      should have_css "a[href*='#{team_path}']", text: 'Team'
      should have_css "a[href*='#{terms_path}']", text: 'Copyright and Terms of Use'
      should have_css "a[href*='#{privacy_path}']", text: 'Privacy'
      should have_css "a[href*='#{contact_path}']", text: 'Contact Us'

      should_not have_css 'a.selected'
    }
  }

  context ( 'with Overview selected' ) {
    before {
      render partial: 'shared/about_panel_menu', locals: { 
        params: { action: 'about' }
      }
    }

    it {
      should have_css 'a.selected', text: 'Overview'
    }

  }
}
