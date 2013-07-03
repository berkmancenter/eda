require "spec_helper"

describe ( "Image model" ) {
  let ( :image ) { Image.first }

  subject { image }

  describe ( "with valid data" ) {
    it { should be_valid }
    it { should respond_to( :url ) }
  }
}
