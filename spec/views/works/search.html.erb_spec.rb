require 'spec_helper'

describe ( 'works/search' ) {
  subject { rendered }

  context ( 'normal work' ) {
    before {
      assign( :search, Work.search do
          fulltext 'awake' do
              fields(:lines, :title => 2.0)
          end
        end
      )

      render
    }

    it {
      should have_css '.search-works'
    }

    it {
      should have_css 'table.works'
    }

    it {
      should have_css 'thead th', text: I18n.t( 'datatable.th_title' )
      should have_css 'thead th', text: I18n.t( 'datatable.th_edition' )
    }

    it {
      should have_css 'th:first-child', text: I18n.t( 'datatable.th_title' )
    }

    it {
      should have_css 'tfoot th.edition-footer'
    }
  }
}
