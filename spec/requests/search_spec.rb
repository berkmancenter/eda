require 'spec_helper'

describe ( 'search requests' ) {
  # require test:seed
  subject { page }

  describe ( 'get /search' ) {
    before { visit search_works_path }

    it ( 'should return a search page' ) {
      should have_selector( 'form[action="/search"]' );
    }

    it ( 'should not have a result list' ) {
      should_not have_selector( '.search-works-results' );
    }
  }

  describe ( 'get /search/awake (default edition)' ) {
    before { visit "#{search_works_path( 'awake' )}" } #?current_edition=3" }

    it ( 'should return a search page' ) {
      should have_selector( 'form[action="/search"]' );
      should have_selector( 'input[name="q"]' );
    }

    it ( 'should have a result list' ) {
      should have_selector( '.search-works-results' );
    }

    it ( 'should have one result' ) {
      should have_css( '.search-works-results a', { count: 1 } );
    }
  }

  describe ( 'get /search/awake?current_edition=1 ( no results in this edition )' ) {
    before { visit "#{search_works_path( 'awake' )}?current_edition=1" }

    it ( 'should return a search page' ) {
      should have_selector( 'form[action="/search"]' );
      should have_selector( 'input[name="q"]' );
    }

    it {
      should have_selector( '.search-works-results' );
    }

    it {
      should_not have_selector( '.search-works-results a' );
    }
  }

  context 'with search submit' do
    before {
      visit search_works_path;
      fill_in( 'Search for:', { with: 'awake' } );
      click_button( 'Search' );
    }

    it ( 'should have performed a search' ) {
      should have_selector( '.search-works form input[name="q"][value="awake"]' );

      should have_selector( '.search-works-results' );

      should have_css( '.search-works-results a', { count: 1 } );
    }
  end
}
