require 'spec_helper'

describe( "Edition model" ) {
  subject { edition }

  context 'with works, and images' do
    let ( :edition ) { Edition.find_by_work_number_prefix 'F' }

    it {
      should be_valid
      should respond_to :work_set
      should respond_to :image_set
    }
  end

  describe '#all_works' do
    context 'user edition with works that modify base edition' do
      pending 'it should have all base edition works'
    end
  end

  describe "#work_after" do
      context "no works exist with a greater number or letter" do
        pending 'it "returns nil"'
      end
      context "a work exists with the same number and a greater variant letter" do
          pending 'it "returns the work with the closest variant letter greater than the current"'
      end
      context "a work exists with a greater number and no greater variants exist" do
          pending 'it "returns the work with the closest number greater than the current"'
      end
  end

  describe "#image_group_after" do
      context "image group has children" do
          pending 'it "returns the first child"'
      end
      context "image group does not have children" do
          pending 'it "returns the next sibling of its closest ancestor to have a next sibling"'
      end
      context "image group is last image group" do
          pending 'it "returns nil"'
      end
  end

  describe "#image_after" do
      context "image group has an image with a greater position number" do
          pending 'it "returns the image with the next greatest position number"'
      end
      context "image group does not have an image with a greater position number" do
          pending 'it "returns the first image of the next image group"'
      end
      context "last image of last image group" do
          pending 'it "returns nil"'
      end
  end

  describe "#images_of_work" do
      pending 'it "returns all the images of the work in reading order"'
  end

  describe "#works_in_image" do
      pending 'it "returns all the works shown in an image ordered by number"'
  end
}
