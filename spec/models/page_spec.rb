require "spec_helper"

describe ( "Page model" ) {
  let ( :page_one ) { FactoryGirl.create( :page_one ) }
  let ( :page_two ) { FactoryGirl.create( :page_two ) }
  let ( :page_three ) { FactoryGirl.create( :page_three ) }
  let ( :page_four ) { FactoryGirl.create( :page_four ) }
  let ( :page_five ) { FactoryGirl.create( :page_five ) }
  let ( :page_six ) { FactoryGirl.create( :page_six ) }

  describe ( "with valid data" ) {
    subject { page_one }

    it { should be_valid }
    it { should respond_to( :work ) }
    it { should respond_to( :image_group_image ) }
    it { should respond_to( :image_url ) }
  }

  describe ( "with valid next page" ) {
    subject { page_one.next }

    it { should be_valid }
    it { should = page_two }
  }
}
