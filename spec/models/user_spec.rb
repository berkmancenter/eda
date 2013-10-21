require 'spec_helper'

describe ( 'User model' ) {
  describe ( 'create' ) {
    context ( 'with valid data' ) {
      it {
        test_user_attr = FactoryGirl.attributes_for :test_user_model
        test_user_model = User.create!( test_user_attr )
        test_user_model.id.should_not eq( nil )
      }
    }
  }
}
