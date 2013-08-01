require 'factory_girl_rails'

namespace :db do
  namespace :test do
    task :seed => :environment do
      Sunspot.remove_all!

      #
      # johnson
      # 
      #johnson = FactoryGirl.create :johnson
      #johnson.save!

      #
      # franklin
      #
      franklin = FactoryGirl.create :franklin

      franklin.create_image_set( FactoryGirl.attributes_for :iset_franklin )
      franklin.create_work_set( FactoryGirl.attributes_for :wset_franklin )

      franklin.save

      # harvard collection root
      # (image set for franklin)
      #iset_harvard = FactoryGirl.create :iset_harvard

      # image sets
      iset_one = FactoryGirl.create :iset_one
      franklin.image_set.children << iset_one

      iset_one_i1 = ImageSet.new
      iset_one_i1.image = FactoryGirl.create( :image_one )
      iset_one_i1.save

      iset_one.children << iset_one_i1

      # not sure what to do about collections, do they get a clone of every iset?
      #iset_harvard.children << FactoryGirl.create( :iset_one )
      #iset_one.parent = iset_harvard;

#      iset_two = FactoryGirl.create( :iset_two );
#      iset_two.edition = franklin;
#      iset_two.parent = iset_harvard;
#      iset_two.save
      #iset_two = FactoryGirl.create :iset_two
      #franklin.image_set.children << iset_two

#
#      iset_three = FactoryGirl.create( :iset_three );
#      iset_three.edition = franklin;
#      iset_three.parent = iset_harvard;
#      iset_three.save
      #iset_three = FactoryGirl.create :iset_three
      #franklin.image_set.children << iset_three

#
#      # some works
# 
#      # work_f1a
      work_f1a = FactoryGirl.create( :work_f1a )
      work_f1a.edition = franklin
      #work_f1a.image_set = iset_one
      work_f1a.save

      wset_f1a = WorkSet.new
      wset_f1a.work = work_f1a
      wset_f1a.save
      franklin.work_set.children << wset_f1a

      z_f1a0 = FactoryGirl.create( :z_f1a0 )
      z_f1a0.work = work_f1a
      z_f1a0.save

      l_f1a01 = FactoryGirl.create( :l_f1a01 );
      l_f1a01.stanza = z_f1a0;
      l_f1a01.save

      l_f1a02 = FactoryGirl.create( :l_f1a02 );
      l_f1a02.stanza = z_f1a0;
      l_f1a02.save

      l_f1a03 = FactoryGirl.create( :l_f1a03 );
      l_f1a03.stanza = z_f1a0;
      l_f1a03.save

      l_f1a04 = FactoryGirl.create( :l_f1a04 );
      l_f1a04.stanza = z_f1a0;
      l_f1a04.save

      l_f1a05 = FactoryGirl.create( :l_f1a05 );
      l_f1a05.stanza = z_f1a0;
      l_f1a05.save

      l_f1a06 = FactoryGirl.create( :l_f1a06 );
      l_f1a06.stanza = z_f1a0;
      l_f1a06.save

      l_f1a07 = FactoryGirl.create( :l_f1a07 );
      l_f1a07.stanza = z_f1a0;
      l_f1a07.save

      work_f1a.index!

#      # work_f2a
#      work_f2a = FactoryGirl.create( :work_f2a );
#      work_f2a.edition = franklin;
#      work_f2a.image_group = iset_two;
#      work_f2a.save!
#
#      # work_f3a
#      work_f3a = FactoryGirl.create( :work_f3a );
#      work_f3a.edition = franklin;
#      work_f3a.image_group = iset_three;
#      work_f3a.save!
#
#      # work_f131a
#      work_f131a = FactoryGirl.create( :work_f131a );
#      work_f131a.edition = franklin;
#      work_f131a.image_group = iset_one;
#      work_f131a.save!
#
#      z_f131a0 = FactoryGirl.create( :z_f131a0 );
#      z_f131a0.work = work_f131a;
#      z_f131a0.save!
#
#      l_f131a01 = FactoryGirl.create( :l_f131a01 );
#      l_f131a01.stanza = z_f131a0;
#      l_f131a01.save!
#
#      # some images
#      image_one = FactoryGirl.create( :image_one );
#      image_one.save!
#
#      image_two = FactoryGirl.create( :image_two );
#      image_two.save!
#
#      image_three = FactoryGirl.create( :image_three );
#      image_three.save!
#
#      image_four = FactoryGirl.create( :image_four );
#      image_four.save!
#
#      image_five = FactoryGirl.create( :image_five );
#      image_five.save!
#
#
      # finally, some pages
      page_one = FactoryGirl.create( :page_one )
      page_one.edition = franklin
      page_one.work_set = wset_f1a
      page_one.image_set = iset_one_i1
      page_one.save

#      page_two = FactoryGirl.create( :page_two );
#      page_two.edition = franklin;
#      page_two.work = work_f1a;
#      page_two.image_group_image = igi_two;
#      page_two.save!
#
#      page_three = FactoryGirl.create( :page_three );
#      page_three.edition = franklin;
#      page_three.work = work_f1a;
#      page_three.image_group_image = igi_three;
#      page_three.save!
#
#      page_four = FactoryGirl.create( :page_four );
#      page_four.edition = franklin;
#      page_four.work = work_f2a;
#      page_four.image_group_image = igi_four;
#      page_four.save!
#
#      page_five = FactoryGirl.create( :page_five );
#      page_five.edition = franklin;
#      page_five.work = work_f2a;
#      page_five.image_group_image = igi_five;
#      page_five.save!
#
#      page_six = FactoryGirl.create( :page_six );
#      page_six.edition = franklin;
#      page_six.work = work_f3a;
#      page_six.image_group_image = igi_six;
#      page_six.save!
#
#      #
#      # tested
#      # 
#      tested = FactoryGirl.create( :tested );
#      tested.save!
#
#      # some works
#      tw = FactoryGirl.create( :work_no_stanzas_no_image_group );
#      tw.edition = tested;
#      tw.save!
#
#      Sunspot.commit
    end
  end
end

