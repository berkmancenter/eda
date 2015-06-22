require 'factory_girl_rails'

namespace :db do
  namespace :test do
    task :seed => :environment do
      Sunspot.remove_all!

      #
      # johnson
      # 
      johnson = Edition.new( FactoryGirl.attributes_for :johnson )
      johnson.create_image_set( FactoryGirl.attributes_for :iset_johnson )
      johnson.create_work_set( FactoryGirl.attributes_for :wset_johnson )
      johnson.save

      #
      # franklin
      #
      franklin = Edition.new( FactoryGirl.attributes_for :franklin )

      # image sets
      franklin_image_set = FactoryGirl.create :iset_franklin

      image_one = FactoryGirl.create( :image_one )
      image_two = FactoryGirl.create( :image_two )
      image_three = FactoryGirl.create( :image_three )
      image_four = FactoryGirl.create( :image_four )
      image_five = FactoryGirl.create( :image_five )

      iset_one = FactoryGirl.create :iset_one
      iset_one.move_to_child_of franklin_image_set

      iset_one << image_one
      iset_one << image_two
      iset_one << image_three

      iset_two = FactoryGirl.create :iset_two
      iset_two.move_to_child_of franklin_image_set

      iset_two << image_three
      iset_two << image_four

      iset_three = FactoryGirl.create :iset_three
      iset_three.move_to_child_of franklin_image_set

      iset_three << image_five

      iset_four = FactoryGirl.create :iset_four
      iset_four.move_to_child_of franklin_image_set

      iset_four << Image.new

      franklin.image_set = franklin_image_set

      # Houghton collection root
      col_houghton = FactoryGirl.create :col_houghton

      iset_houghton = FactoryGirl.create :iset_houghton
      iset_houghton.move_to_child_of col_houghton

      iset_houghton << image_one
      iset_houghton << image_five
      iset_houghton << image_two
      iset_houghton << image_four
      iset_houghton << image_three

      # some works
      franklin_work_set = FactoryGirl.create :wset_franklin
 
      # work_f1a
      work_f1a = FactoryGirl.create( :work_f1a )
      work_f1a.edition = franklin
      work_f1a.image_set = iset_one
      work_f1a.save

      wset_f1a = WorkSet.new
      wset_f1a.work = work_f1a
      wset_f1a.save
      wset_f1a.move_to_child_of franklin_work_set

      z_f1a0 = FactoryGirl.create( :z_f1a0 )
      z_f1a0.work = work_f1a
      z_f1a0.lines << FactoryGirl.create( :l_f1a01 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a02 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a03 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a04 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a05 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a06 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a07 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a08 )
      z_f1a0.save

      work_f1a.line_modifiers << FactoryGirl.create( :d_f1a03 )
      work_f1a.line_modifiers << FactoryGirl.create( :d_f1a06 )

      e_f1a08 = FactoryGirl.create( :e_f1a08 )
      d_f1a08 = FactoryGirl.create( :d_f1a08 )
      e_f1a08.children << d_f1a08
      work_f1a.line_modifiers << e_f1a08
      work_f1a.line_modifiers << d_f1a08

      work_f1a.save

      work_f1a.index!

      # work_f2a
      work_f2a = FactoryGirl.create( :work_f2a )
      work_f2a.edition = franklin
      work_f2a.image_set = iset_two
      work_f2a.save

      wset_f2a = WorkSet.new
      wset_f2a.work = work_f2a
      wset_f2a.save
      wset_f2a.move_to_child_of franklin_work_set

      # work_f3a
      work_f3a = FactoryGirl.create( :work_f3a )
      work_f3a.edition = franklin
      work_f3a.image_set = iset_three
      work_f3a.save

      wset_f3a = WorkSet.new
      wset_f3a.work = work_f3a
      wset_f3a.save
      wset_f3a.move_to_child_of franklin_work_set

      # work_f131a
      work_f131a = FactoryGirl.create( :work_f131a )
      work_f131a.edition = franklin
      work_f131a.image_set = iset_four
      work_f131a.save

      wset_f131a = WorkSet.new
      wset_f131a.work = work_f131a
      wset_f131a.save
      wset_f131a.move_to_child_of franklin_work_set

      z_f131a0 = FactoryGirl.create( :z_f131a0 )
      z_f131a0.work = work_f131a
      z_f131a0.lines << FactoryGirl.create( :l_f131a01 )
      z_f131a0.save

      work_f131a.index!

      franklin.work_set = franklin_work_set

      franklin.save

      #
      # tested
      # 
      tested = Edition.new( FactoryGirl.attributes_for :tested )
      tested.create_work_set( FactoryGirl.attributes_for :wset_tested )

      # image sets
      tested_image_set = FactoryGirl.create :iset_tested

      iset_no_stanzas = FactoryGirl.create( :iset_no_stanzas )
      iset_no_stanzas.move_to_child_of tested_image_set

      iset_no_stanzas << Image.new

      tested.image_set = tested_image_set

      # some works
      tw_no_stanzas = FactoryGirl.create :tw_no_stanzas
      tw_no_stanzas.edition = tested
      tw_no_stanzas.image_set = iset_no_stanzas
      tw_no_stanzas.save

      wset_tw_no_stanzas = WorkSet.new
      wset_tw_no_stanzas.work = tw_no_stanzas
      wset_tw_no_stanzas.save
      tested.work_set.children << wset_tw_no_stanzas

      tested.save

      # words
      
      awake = FactoryGirl.create :awake
      awake_adj = FactoryGirl.create :awake_adj
      awake_adj.definitions << FactoryGirl.create( :awake_one )
      awake_adj.definitions << FactoryGirl.create( :awake_two )
      awake_adj.save

      # user
      if User.count == 0
        test_user_attr = FactoryGirl.attributes_for :test_user
        test_user = User.create!( test_user_attr )
      end

      Sunspot.commit
    end
  end
end

