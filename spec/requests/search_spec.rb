require 'spec_helper'

describe ( 'search requests' ) {

  let ( :awake ) { 'Awake ye muses nine, sing me a strain divine' }
  let ( :awake_work ) { Work.find_by_title( awake ) }
  let ( :awake_iset_path ) { edition_image_set_path( awake_work.edition, awake_work.image_set.children.first ) }

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

  describe 'get /search/awake (default edition)', :js => true do
    before { visit "#{search_works_path( 'awake' )}" } #?current_edition=3" }

    it ( 'should return a search page' ) {
      should have_selector( 'form[action="/search"]' );
      should have_selector( 'input[name="q"]' );
    }

    it ( 'should have secondary text filter' ) {
      should have_css 'label', text: 'Search within these results:'
    }

    it ( 'should have a result table' ) {
      should have_selector( '#work-table-wrapper' );
    }

    it ( 'should have one result' ) {
      should have_css 'h2', text: '1 result'
      should have_css "a[href='#{awake_iset_path}']"
    }
  end

  describe 'get /search/awake?current_edition=1 ( no results in this edition )', :js => true do
    before { visit "#{search_works_path( 'awake' )}?current_edition=1" }

    it ( 'should return a search page' ) {
      should have_selector( 'form[action="/search"]' );
      should have_selector( 'input[name="q"]' );
    }

    it ( 'should have a result table' ) {
      should have_selector( '#work-table-wrapper' );
    }

    it {
      should_not have_css "a[href='#{awake_iset_path}']"
    }
  end

  context 'with search submit' do
    before {
      visit search_works_path;
      fill_in( 'Search for:', { with: 'awake' } );
      click_button( 'Search' );
    }

    it ( 'should have performed a search' ) {
      find( '.search-works-form input[name="q"]' ).value.should eq( 'awake' )

      should have_selector( '#work-table-wrapper' );

      should have_css "a[href='#{awake_iset_path}']"
    }
  end
}
