require 'spec_helper'

describe ( ImageSetsController ) {
  let ( :e ) { Edition.find_by_work_number_prefix 'F' }
  let ( :i ) { Image.find_by_url 'ms_am_1118_10_10_0001' }
  let ( :is ) { e.image_set.leaves_containing( i ).first }

  describe ( 'GET show' ) {
    context ( 'leaf/page view' ) {
      context ( 'with valid params' ) {
        it {
          get :show, edition_id: e.id, id: is.id
          response.code.should eq( '200' )
        }
      }

      context ( 'with nonexistant id' ) {
        it {
          get :show, edition_id: e.id, id: 31337
          response.code.should eq( '404' )
        }
      }
    }
  }
}


