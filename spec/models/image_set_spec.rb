require 'spec_helper'

describe 'ImageSet model' do
  describe 'Edition ImageSet' do
    let ( :fis ) { Edition.find_by_name( 'The Poems of Emily Dickinson: Variorum Edition' ).image_set }

    it do
      fis.should be_valid
    end

    it do
      fis.image.should eq( nil )
    end

    it do
      fis.children.count.should eq( 3 )
    end
  end

  describe 'Image ImageSet' do
    let ( :iis ) { ImageSet.find_by_name( 'Awake ye muses nine, sing me a strain divine' ).children.first }

    it do 
      iis.should be_valid
    end

    it do 
      iis.image.should_not eq( nil )
    end

    it 'should not have children' do
      iis.children.count.should eq( 0 )
    end

  end
end
