FactoryGirl.define do
  factory :edition do
    factory :johnson do
      name "The Poems of Emily Dickinson"
      author "Thomas H. Johnson"
      date "1951-01-01"
      work_number_prefix "J"
      completeness 0.95
    end

    factory :franklin do
      name "The Poems of Emily Dickinson: Variorum Edition"
      author "R. W. Franklin"
      date "1998-01-01"
      work_number_prefix "F"
      completeness 1
    end

    factory :tested do
      name 'Test Edition'
      author 'Ryan Westphal'
      date '2013-06-06'
      work_number_prefix 'R'
      completeness 0.1
    end
  end

  factory :work do
    #edition :johnson

    #edition :franklin

    factory :work_f1a do
      title 'Awake ye muses nine, sing me a strain divine'
      number 1
      variant 'A'
      #image_group :igrp_one
    end

    factory :work_f2a do
      title 'Sic transit gloria mundi'
      number 2
      variant 'A'
      #image_group :igrp_two
    end

    factory :work_f2b do
      title 'Sic transit gloria mundi'
      number 2
      variant 'B'
      #image_group nil
    end

    factory :work_f3a do
      title 'On this wondrous sea'
      number 3
      variant 'A'
      #image_group :igrp_three
    end

    factory :work_f3b do
      title 'On this wondrous sea'
      number 3
      variant 'B'
      #image_group nil
    end

    factory :work_variant do
      title "Sic transit gloria mundi"
      date "1852-01-01"
      number 2
      variant "B"
    end

    #edition :tested

    factory :work_no_stanzas_no_image_group do
      title "no_stanzas, no_image_group"
      number 1
    end


  end

  factory :stanza do

    #work :work_three
  end

  # metadata is not designed enough to test
  factory :image do
    factory :image_one do
      url "ms_am_1118_10_10_0001"
      metadata {{ 'Imported' => '2013-07-11 12:00:00 -0400' }}
      credits "Provided by Harvard University"
      web_width 500
      web_height 750
    end

    factory :image_two do
      url "ms_am_1118_10_10_0002"
      metadata {{ 'Imported' => '2013-07-11 12:00:00 -0400' }}
      credits "Provided by Harvard University"
      web_width 500
      web_height 748
    end

    factory :image_three do
      url "ms_am_1118_10_10_0003"
      metadata {{ 'Imported' => '2013-07-11 12:00:00 -0400' }}
      credits "Provided by Harvard University"
      web_width 500
      web_height 746
    end

    factory :image_four do
      url "ms_am_1118_10_10_0004"
      metadata {{ 'Imported' => '2013-07-11 12:00:00 -0400' }}
      credits "Provided by Harvard University"
      web_width 549
      web_height 750
    end

    factory :image_five do
      url "ms_am_1118_10_10_0005"
      metadata {{ 'Imported' => '2013-07-11 12:00:00 -0400' }}
      credits "Provided by Harvard University"
      web_width 500
      web_height 745
    end
  end

  factory :image_group do 
    factory :igrp_harvard do
      name "Harvard Collection"
      #parent nil
      metadata {{ "Library" => "Houghton" }}
      edition nil
      type "Collection"
    end

    # an image group contains all the images for a poem and their order
    factory :igrp_one do
      name 'Awake ye muses nine, sing me a strain divine'
      #parent :igrp_harvard
      metadata nil
      type nil
    end

    factory :igrp_two do
      name 'Sic transit gloria mundi'
      #parent :igrp_harvard
      metadata nil
      type nil
    end

    factory :igrp_three do
      name 'On this wondrous sea'
      #parent :igrp_harvard
      metadata nil
      type nil
    end
  end

  factory :image_group_image do
    factory :igi_one do
      #image_group :igrp_one
      #image :image_one
      position 1
    end

    factory :igi_two do
      #image_group :igrp_one
      #image :image_two
      position 2
    end

    factory :igi_three do
      #image_group :igrp_one
      #image :image_three
      position 3
    end

    factory :igi_four do
      #image_group :igrp_two
      #image :image_three
      position 1
    end

    factory :igi_five do
      #image_group :igrp_two
      #image :image_four
      position 2
    end

    factory :igi_six do
      #image_group :igrp_three
      #image :image_five
      position 1
    end
  end

  # visually, the following pages (work/image combo) look like this, where the numbers are work numbers and the blocks are scanned images
  #
  # 11111 11111 11111 22222 33333
  # 11111 11111       22222 33333
  # 11111 11111 22222       33333
  # 11111 11111 22222
  #

  factory :page do
    # edition :franklin

    factory :page_one do
      #work :work_f1a
      #image_group_image :igi_one
    end

    factory :page_two do
      #work :work_f1a
      #image_group_image :igi_two
    end

    factory :page_three do
      #work :work_f1a
      #image_group_image :igi_three
    end

    factory :page_four do
      #work :work_f2a
      #image_group_image :igi_four
    end

    factory :page_five do
      #work :work_f2a
      #image_group_image :igi_five
    end

    factory :page_six do
      #work :work_f3a
      #image_group_image :igi_six
    end
  end
end


