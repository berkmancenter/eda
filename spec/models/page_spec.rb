require "spec_helper"

describe ( "Page model" ) {
  # page ids are entered by design
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

  describe ( "next page having same work/different image" ) {
    it {
      page_one_next = page_one.next;
      page_one_next.work_id.should = page_one.work_id;
      page_one_next.image_url.should_not = page_one.image_url;
    }
  }
}
