require 'spec_helper'

describe ( 'list_item' ) {
  let ( :awake ) { 'Awake ye muses nine, sing me a strain divine' }
  let ( :awake_work ) { Work.find_by_title( awake ) }
    
  subject { rendered }

  context ( 'normal work' ) {
    before {
      # todo: pending because I don't know how to alert the spec to the ApplicationController helper_method
      #render partial: 'works/list_item', locals: { work: awake_work }
    }

    it {
      pending 'should have work-list-item'
      should have_selector 'li.work-list-item'
    }
  }
}
