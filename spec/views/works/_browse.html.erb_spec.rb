require 'spec_helper'

describe ( '_browse' ) {
  subject { rendered }

  before {
    render partial: 'works/browse'
  }

  it {
    # panel header selected in menu above
    should_not have_css 'h2', text: 'Browse'
  }
}
