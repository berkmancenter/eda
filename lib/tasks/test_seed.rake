require 'factory_girl_rails'

namespace :db do
  namespace :test do
    task :prepare => :environment do

      #
      # johnson
      # 
      johnson = FactoryGirl.create( :johnson );
      johnson.save!

      #
      # franklin
      #
      franklin = FactoryGirl.create( :franklin );
      franklin.save!

      # harvard collection root
      # (image group for franklin)
      igrp_harvard = FactoryGirl.create( :igrp_harvard );
      igrp_harvard.save!

      franklin.root_image_group = igrp_harvard;
      franklin.save!

      # image groups (do these need edition?)
      igrp_one = FactoryGirl.create( :igrp_one );
      igrp_one.parent_group = igrp_harvard;
      igrp_one.save!

      igrp_two = FactoryGirl.create( :igrp_two );
      igrp_two.parent_group = igrp_harvard;
      igrp_two.save!

      igrp_three = FactoryGirl.create( :igrp_three );
      igrp_three.parent_group = igrp_harvard;
      igrp_three.save!

      # some works
      work_one = FactoryGirl.create( :work_one );
      work_one.edition = franklin;
      work_one.image_group = igrp_one;
      work_one.save!

      work_two = FactoryGirl.create( :work_two );
      work_two.edition = franklin;
      work_two.image_group = igrp_two;
      work_two.save!

      work_three = FactoryGirl.create( :work_three );
      work_three.edition = franklin;
      work_three.image_group = igrp_three;
      work_three.save!

      # some images
      image_one = FactoryGirl.create( :image_one );
      image_one.save!

      image_two = FactoryGirl.create( :image_two );
      image_two.save!

      image_three = FactoryGirl.create( :image_three );
      image_three.save!

      image_four = FactoryGirl.create( :image_four );
      image_four.save!

      image_five = FactoryGirl.create( :image_five );
      image_five.save!

      # image group images
      igi_one = FactoryGirl.create( :igi_one );
      igi_one.image_group = igrp_one;
      igi_one.image = image_one;
      igi_one.save!

      igi_two = FactoryGirl.create( :igi_two );
      igi_two.image_group = igrp_one;
      igi_two.image = image_two;
      igi_two.save!

      igi_three = FactoryGirl.create( :igi_three );
      igi_three.image_group = igrp_one;
      igi_three.image = image_three;
      igi_three.save!

      igi_four = FactoryGirl.create( :igi_four );
      igi_four.image_group = igrp_two;
      igi_four.image = image_three;
      igi_four.save!

      igi_five = FactoryGirl.create( :igi_five );
      igi_five.image_group = igrp_two;
      igi_five.image = image_four;
      igi_five.save!

      igi_six = FactoryGirl.create( :igi_six );
      igi_six.image_group = igrp_three;
      igi_six.image = image_five;
      igi_six.save!


      # finally, some pages
      page_one = FactoryGirl.create( :page_one );
      page_one.edition = franklin;
      page_one.work = work_one;
      page_one.image_group_image = igi_one;
      page_one.save!

      page_two = FactoryGirl.create( :page_two );
      page_two.edition = franklin;
      page_two.work = work_one;
      page_two.image_group_image = igi_two;
      page_two.save!

      page_three = FactoryGirl.create( :page_three );
      page_three.edition = franklin;
      page_three.work = work_one;
      page_three.image_group_image = igi_three;
      page_three.save!

      page_four = FactoryGirl.create( :page_four );
      page_four.edition = franklin;
      page_four.work = work_two;
      page_four.image_group_image = igi_four;
      page_four.save!

      page_five = FactoryGirl.create( :page_five );
      page_five.edition = franklin;
      page_five.work = work_two;
      page_five.image_group_image = igi_five;
      page_five.save!

      page_six = FactoryGirl.create( :page_six );
      page_six.edition = franklin;
      page_six.work = work_three;
      page_six.image_group_image = igi_six;
      page_six.save!

      #
      # tested
      # 
      tested = FactoryGirl.create( :tested );
      tested.save!

      # some works
      tw = FactoryGirl.create( :work_no_stanzas_no_image_group );
      tw.edition = tested;
      tw.save!

    end
  end
end

