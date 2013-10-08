require 'factory_girl_rails'

namespace :db do
  namespace :test do
    task :seed => :environment do
      Sunspot.remove_all!

      #
      # johnson
      # 
      johnson = FactoryGirl.create :johnson
      johnson.create_image_set( FactoryGirl.attributes_for :iset_franklin )
      johnson.create_work_set( FactoryGirl.attributes_for :wset_franklin )
      johnson.save

      #
      # franklin
      #
      franklin = FactoryGirl.create :franklin
      franklin.create_image_set( FactoryGirl.attributes_for :iset_franklin )
      franklin.create_work_set( FactoryGirl.attributes_for :wset_franklin )
      franklin.save

      # image sets
      image_one = FactoryGirl.create( :image_one )
      image_two = FactoryGirl.create( :image_two )
      image_three = FactoryGirl.create( :image_three )
      image_four = FactoryGirl.create( :image_four )
      image_five = FactoryGirl.create( :image_five )

      iset_one = FactoryGirl.create :iset_one
      franklin.image_set.children << iset_one

      iset_one << image_one
      iset_one << image_two
      iset_one << image_three

      iset_two = FactoryGirl.create :iset_two
      franklin.image_set.children << iset_two

      iset_two << image_three
      iset_two << image_four

      iset_three = FactoryGirl.create :iset_three
      franklin.image_set.children << iset_three

      iset_three << image_five

      iset_four = FactoryGirl.create :iset_four
      franklin.image_set.children << iset_four

      iset_four << Image.new

      # harvard collection root
      # (image set for franklin)
      #iset_harvard = FactoryGirl.create :iset_harvard

      # not sure what to do about collections, do they get a clone of every iset?
      # an iset can not have more than one parent
      #iset_harvard.children << FactoryGirl.create( :iset_one )
      #iset_one.parent = iset_harvard


      # some works
 
      # work_f1a
      work_f1a = FactoryGirl.create( :work_f1a )
      work_f1a.edition = franklin
      work_f1a.image_set = iset_one
      work_f1a.save

      wset_f1a = WorkSet.new
      wset_f1a.work = work_f1a
      wset_f1a.save
      franklin.work_set.children << wset_f1a

      z_f1a0 = FactoryGirl.create( :z_f1a0 )
      z_f1a0.work = work_f1a
      z_f1a0.lines << FactoryGirl.create( :l_f1a01 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a02 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a03 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a04 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a05 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a06 )
      z_f1a0.lines << FactoryGirl.create( :l_f1a07 )
      z_f1a0.save

      work_f1a.divisions << FactoryGirl.create( :d_f1a03 )
      work_f1a.divisions << FactoryGirl.create( :d_f1a06 )
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
      franklin.work_set.children << wset_f2a

      # work_f3a
      work_f3a = FactoryGirl.create( :work_f3a )
      work_f3a.edition = franklin
      work_f3a.image_set = iset_three
      work_f3a.save

      wset_f3a = WorkSet.new
      wset_f3a.work = work_f3a
      wset_f3a.save
      franklin.work_set.children << wset_f3a

      # work_f131a
      work_f131a = FactoryGirl.create( :work_f131a )
      work_f131a.edition = franklin
      work_f131a.image_set = iset_four
      work_f131a.save

      wset_f131a = WorkSet.new
      wset_f131a.work = work_f131a
      wset_f131a.save
      franklin.work_set.children << wset_f131a

      z_f131a0 = FactoryGirl.create( :z_f131a0 )
      z_f131a0.work = work_f131a
      z_f131a0.lines << FactoryGirl.create( :l_f131a01 )
      z_f131a0.save

      work_f131a.index!

      #
      # tested
      # 
      tested = FactoryGirl.create( :tested )
      tested.create_image_set( FactoryGirl.attributes_for :iset_tested )
      tested.create_work_set( FactoryGirl.attributes_for :wset_tested )
      tested.save

      # image sets
      iset_no_stanzas = FactoryGirl.create( :iset_no_stanzas )
      tested.image_set.children << iset_no_stanzas

      iset_no_stanzas << Image.new

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

      Sunspot.commit
    end
  end
end

