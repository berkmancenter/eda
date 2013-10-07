# we will use /about as our test of basic layout elements

require 'spec_helper'

describe 'layout requests' do
  subject { page }

  describe 'get sample page' do
    before { visit about_path }

    it { should have_selector( 'header' ) }

    it { should have_selector( 'header h1' ) }

    it { should have_selector( 'header nav.main' ) }
    it { should have_selector( 'header nav.main a[href*="' + root_path + '"]', { text: 'Home' } ) }
    it { should have_selector( 'header nav.main a[href*="' + about_path + '"]', { text: 'About' } ) }

    it { should have_selector( 'header nav.user' ) }

    context ( 'without being signed in' ) {
      it {
        should have_css 'header nav.user a[href*="' + new_user_session_path + '"]', text: 'Sign In'
      }
    }

    it { should have_selector( 'footer' ) }

    it { should have_selector( 'footer a[title="Berkman Center for Internet and Society"]' ) }

    it { should have_selector( 'footer nav.footer' ) }

    it { should have_selector( 'footer nav.footer a[href*="' + terms_path + '"]', { text: 'Copyright and Terms of Use' } ) }
    it { should have_selector( 'footer nav.footer a[href*="' + privacy_path + '"]', { text: 'Privacy' } ) }
    it { should have_selector( 'footer nav.footer a[href*="' + contact_path + '"]', { text: 'Contact Us' } ) }
  end

end

