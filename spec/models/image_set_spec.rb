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
      fis.children.count.should eq( 4 )
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

    describe 'leaf_after' do
      context 'image_set has an image with a greater position number' do
        it { pending 'returns the image with the next greatest position number' }
      end

      context 'image_set does not have an image with a greater position number' do
        it { pending 'returns the first image of the next image_set' }
      end

      context 'last image of last image_set' do
        it { pending 'returns nil' }
      end
    end

  end
end
