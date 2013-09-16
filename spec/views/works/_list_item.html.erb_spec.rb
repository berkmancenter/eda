require 'spec_helper'

describe ( '_list_item' ) {
  let ( :awake ) { 'Awake ye muses nine, sing me a strain divine' }
  let ( :awake_work ) { Work.find_by_title( awake ) }
    
  subject { rendered }

  context ( 'normal work' ) {
    before {
      render partial: 'works/list_item', locals: { work: awake_work }
    }

    it {
      should have_css 'li.work-list-item'
      should have_css 'li.work-list-item a.work-link'
    }

    it {
      should have_css 'a.work-link div.work-title', text: awake, exact: true
      should have_css 'a.work-link div.work-edition-name', text: awake_work.edition.name, exact: true
    }
  }
}
