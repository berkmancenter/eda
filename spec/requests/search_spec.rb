require 'spec_helper'

describe ( 'search requests' ) {
  subject { page }

  describe ( 'get /search' ) {
    before { visit search_works_path }

    it ( 'should return a search page' ) {
      should have_selector( 'form[action="/search"]' );
    }

    it ( 'should not have a result list' ) {
      should_not have_selector( '.search-results' );
    }
  }

  describe ( 'get /search/awake (default edition)' ) {
    # require test:seed
    before { visit "#{search_works_path( 'awake' )}" } #?current_edition=3" }

    it ( 'should return a search page' ) {
      should have_selector( 'form[action="/search"]' );
      should have_selector( 'input[name="q"]' );
    }

    it ( 'should have a result list' ) {
      should have_selector( '.search-results' );
    }

    it ( 'should have one result' ) {
      should have_css( '.search-results a', { count: 1 } );
    }
  }

  describe ( 'get /search/awake?current_edition=1 ( no results in this edition )' ) {
    # require test:seed
    before { visit "#{search_works_path( 'awake' )}?current_edition=1" }

    it ( 'should return a search page' ) {
      should have_selector( 'form[action="/search"]' );
      should have_selector( 'input[name="q"]' );
    }

    it {
      should have_selector( '.search-results' );
    }

    it {
      should_not have_selector( '.search-results a' );
    }
  }
}
