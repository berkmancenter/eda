require 'spec_helper'

describe( "Edition model" ) {
  subject { edition }

  describe( "with valid data" ) {
    let ( :edition ) { Edition.find_by_work_number_prefix( 'J' ) }

    it {
      should be_valid
    }
  }

  describe "#work_after" do
      context "no works exist with a greater number or letter" do
          it "returns nil"
      end
      context "a work exists with the same number and a greater variant letter" do
          it "returns the work with the closest variant letter greater than the current"
      end
      context "a work exists with a greater number and no greater variants exist" do
          it "returns the work with the closest number greater than the current"
      end
  end

  describe "#image_group_after" do
      context "image group has children" do
          it "returns the first child"
      end
      context "image group does not have children" do
          it "returns the next sibling of its closest ancestor to have a next sibling"
      end
  end

  describe "#image_after" do
  end

  describe "#images_of_work" do
      it "returns all the images of the work in reading order"
  end

  describe "#works_in_image" do
      it "returns all the works shown in an image ordered by number"
  end
}
