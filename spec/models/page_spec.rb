require "spec_helper"

describe Page do
  # tied to specific test data
  let ( :page_one ) { Page.find( 1 ) }
  let ( :page_two ) { Page.find( 2 ) }
  #let ( :page_two ) { FactoryGirl.create( :page_two ) }
  #let ( :page_three ) { FactoryGirl.create( :page_three ) }
  #let ( :page_four ) { FactoryGirl.create( :page_four ) }
  #let ( :page_five ) { FactoryGirl.create( :page_five ) }
  #let ( :page_six ) { FactoryGirl.create( :page_six ) }

  describe ( "with valid data" ) {
    subject { page_one }

    it { should be_valid }
    it { should respond_to( :work ) }
    it { should respond_to( :image_group_image ) }
    it { should respond_to( :image_url ) }
  }

  describe "#next" do
      context "has a work an no image" {}
      context "has an image and no work" {}
      describe ( "current image and work are the last image and work" ) {
          it "returns nil" {}
      }
      describe ( "current image is the last, but current work is not the last" ) {
          it "returns a page containing the next work and no image" {}
      }
      describe ( "current work is the last, but current image is not the last" ) {
          it "returns a page containing the next image and no work" {}
      }
      describe ( "next page is a work without any images" ) {
          it "returns a page containing the next work and no image" {}
      }
      describe ( "next page is an image without any associated works" ) {
          it "returns a page containing the next image and no work" {}
      }
      describe ( "current work continues onto another image" ) {}
      describe ( "current image shows current work and another work" ) {
          it {
          page_one_next = page_one.next;
          page_one_next.work_id.should eq( page_one.work_id );
          page_one_next.image_url.should_not eq( page_one.image_url );
      }
      }
      describe ( "next page with different image and different work" ) {}
  end
end
