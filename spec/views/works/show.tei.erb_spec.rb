require 'spec_helper'

describe ( 'show tei' ) {
  subject { rendered }

  let ( :edition ) {
    mock_model Edition, name: 'Test Edition'
  }

  let ( :work ) {
    stub_model Work, edition: edition, title: 'Test Work', full_id: 523
  }

  before {
    assign( :work, work )

    render file: Rails.root.join( 'app/views/works/show.tei' )
  }

  it { should have_css 'body' }
  it { should have_css 'div[type="transcript"]' }

  it ( 'should have xml id' ) {
    expect(rendered).to include( 'xml:id="523"' )
  }
}
