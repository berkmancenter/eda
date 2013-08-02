require 'spec_helper'

include ImagesHelper;

describe ( 'image sets requests (sbs)' ) {
  subject { page }

  describe ( 'get /editions/:edition_id/image_sets/:id' ) {

    describe ( 'with valid image set having multiple images' ) {
      let ( :edpage ) { Page.first }
      let ( :iset_image ) { edpage.image_set }
      let ( :iset_work_images ) { iset_image.parent }

      before { visit edition_image_set_path( { edition_id: edpage.edition_id, id: iset_work_images.id } ) }

      it { 
        should have_title iset_work_images.name
      }

      it ( 'should have img tags for all ImageSet images' ) {
        should have_selector( "img[src*='#{preview_url( iset_work_images.children[0].image )}']" );
        should have_selector( "img[src*='#{preview_url( iset_work_images.children[1].image )}']" );
        should have_selector( "img[src*='#{preview_url( iset_work_images.children[2].image )}']" );
      }

      it ( 'should include turn.js' ) {
        should have_css( 'script[src*="turn.min.js"]', { visible: false } )
      }
    }
  }
}


