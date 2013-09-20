require 'spec_helper'

describe ( 'shared/_image_panel' ) {
  let ( :awake ) { 'Awake ye muses nine, sing me a strain divine' }
  let ( :awake_work ) { Work.find_by_title( awake ) }
  let ( :image_set ) { awake_work.image_set.children.first }
  let ( :image_one ) { Image.find_by_url( 'ms_am_1118_10_10_0001' ) }
    
  subject { rendered }

  context ( 'normal work' ) {
    before {
      render partial: 'shared/image_panel', locals: { 
        edition: awake_work.edition,
        image_set: image_set,
        note: nil,
        next_image: image_set.root.leaf_after(image_set),
        previous_image: image_set.root.leaf_before(image_set)
      }
    }

    it {
      should have_css '#interactive-image-panel'
      should have_css '#interactive-image-panel .interactive-image'
    }


    it ( 'should no longer have page controls in with interactive image' ) {
      # page controls now part of drawer
      should_not have_css '.interactive-image .page-controls'
    }

    it ( 'should have interactive-image & image-drawer as siblings' ) {
      should have_css '.interactive-image~.image-drawer'
    }

    it ( 'should have page controls, image info, & notes in drawer' ) {
      should have_css '.image-drawer.drawer'
      should have_css '.image-drawer .page-controls'
      should have_css '.image-drawer .image-drawer-tabs'
      should have_css '.image-drawer .image-drawer-content'
    }

    it ( 'should have tab interface for drawer content' ) {
      # tabs
      should have_css '.image-drawer-tabs a.drawer-handle[data-drawer="image-set-info"]', text: I18n.t( :image_info )
      should have_css '.image-drawer-tabs a.drawer-handle[data-drawer="set-notes"]', text: I18n.t( :my_notes )

      # content
      should have_css '.image-drawer-content #image-set-info'
      should have_css '.image-drawer-content #set-notes'
    }

    it ( 'should not treat set info & notes as separate drawers' ) {
      should_not have_css '#image-set-info.drawer'
      should_not have_css '#set-notes.drawer'
    }
  }
}
