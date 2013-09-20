require 'spec_helper'

describe ( 'image_sets/_info' ) {
  let ( :image_one ) { Image.find_by_url( 'ms_am_1118_10_10_0001' ) }
    
  subject { rendered }

  context ( 'normal work' ) {
    before {
      render partial: 'image_sets/info', locals: { image: image_one }
    }

    it {
      should have_css 'dt.image-credits', text: 'Credits'
      should have_css 'dd', text: image_one.credits
    }

    it ( 'should have credits first' ) {
      should have_css 'dt.image-credits:first-child'
    }

    it {
      should have_css 'dt', text: 'Imported'
      should have_css 'dd', text: image_one.metadata[ 'Imported' ]

    }
  }
}
