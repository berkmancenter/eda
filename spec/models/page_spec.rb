# removed, but most of these can be applied to image_set when it's a leaf node

#require "spec_helper"
#
#describe Page do
#  # tied to specific test data
#  let ( :page_one ) { Page.find( 1 ) }
#  let ( :page_two ) { Page.find( 2 ) }
#  let ( :page_three ) { Page.find( 3 ) }
#  let ( :page_four ) { Page.find( 4 ) }
#  let ( :page_five ) { Page.find( 5 ) }
#  let ( :page_six ) { Page.find( 6 ) }
#
#  describe ( "with valid data" ) {
#    subject { page_one }
#
#    it { should be_valid }
#    it { should respond_to( :work_set ) }
#    it { should respond_to( :work ) }
#    it { should respond_to( :image_set ) }
#    it { should respond_to( :image ) }
#  }
#
#  describe "#next" do
#      context "has a work and no image" do
#          pending 'it "returns the page containing the next work"'
#      end
#      context "has an image and no work" do
#          # This shouldn't happen
#          pending 'it "returns the page containing the next image"'
#      end
#      context "current work continues onto another image" do
#          it "returns the page containing the same work and the work's next image" do
#              # pages 1, 2, and 4 in test data
#              page_two_next = page_two.next
#              page_two_next.work.id.should eq( page_two.work.id )
#              page_two_next.image.url.should_not eq( page_two.image.url )
#          end
#      end
#      context "has both an image and a work" do
#          it "returns the next work" do
#            page_one_next = page_one.next
#            page_one_next.should_not eq( nil )
#            page_one_next.should_not == page_one
#          end
#      end
#      context "current image and work are the last image and work" do
#        it 'returns nil' do
#          # page_six in test data
#          page_six_next = page_six.next
#          page_six_next.should eq( nil )
#        end
#      end
#      context "current image is the last, but current work is not the last" do
#          pending 'it "returns a page containing the next work and no image"'
#      end
#      context "current work is the last, but current image is not the last" do
#          pending 'it "returns a page containing the next image and no work"'
#      end
#      context "current image shows current work and another work" do
#          it "ignores the other work and returns the next work by number" do
#              # page_three in test data
#              page_three_next = page_three.next
#              page_three_next.work.id.should_not eq( page_three.work.id )
#              page_three_next.image.url.should eq( page_three.image.url )
#          end
#      end
#  end
#end
