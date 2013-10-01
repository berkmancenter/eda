require 'spec_helper'

describe( "Edition model" ) {
  let ( :franklin ) { Edition.find_by_work_number_prefix 'F' }

  subject { franklin }

  context 'with works, and images' do

    it {
      should be_valid
      should respond_to :work_set
      should respond_to :image_set
    }
  end

  describe ( 'all_works' ) {
    context ( 'normal edition' ) {
      it {
        all_works = franklin.all_works
        all_works.count.should eq( Work.where( { edition_id: franklin.id } ).count )
      }
    }

    context 'user edition with works that modify base edition' do
      it {
        pending 'should have all base edition works'
      }
    end
  }
}
