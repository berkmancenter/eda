require 'spec_helper'

describe ( 'image groups requests (sbs)' ) {
  subject { page }

  describe ( 'get /editions/:edition_id/image_groups/:id' ) {

    describe ( 'with valid image group having multiple images' ) {
      let ( :igrp_name ) { 'Awake ye muses nine, sing me a strain divine' }
      let ( :igrp ) { ImageGroup.find_by_name( igrp_name ) }

      before { visit edition_image_group_url( { edition_id: igrp.edition_id, id: igrp.id } ) }

      it { 
        should have_selector( 'title', { text: igrp_name } );
      }

      it ( 'should have img tags for all ImageGroup images' ) {
        should have_selector( "img[src*='#{igrp.images[0].image.preview_url}']" );
        should have_selector( "img[src*='#{igrp.images[1].image.preview_url}']" );
        should have_selector( "img[src*='#{igrp.images[2].image.preview_url}']" );
      }

    }
  }
}


