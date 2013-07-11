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
      context "has a work and no image" do
          pending 'it "returns the page containing the next work"'
      end
      context "has an image and no work" do
          # This shouldn't happen
          pending 'it "returns the page containing the next image"'
      end
      context "current work continues onto another image" do
          pending 'it "returns the page containing the same work and the work\'s next image"'
      end
      context "has both an image and a work" do
          it "returns the next work"
      end
      context "current image and work are the last image and work" do
          pending 'it "returns nil"'
      end
      context "current image is the last, but current work is not the last" do
          pending 'it "returns a page containing the next work and no image"'
      end
      context "current work is the last, but current image is not the last" do
          pending 'it "returns a page containing the next image and no work"'
      end
      context "current image shows current work and another work" do
          it "ignores the other work and returns the next work by number" do
              page_one_next = page_one.next;
              page_one_next.work_id.should eq( page_one.work_id );
              page_one_next.image_url.should_not eq( page_one.image_url );
          end
      end
  end
end
