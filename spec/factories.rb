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

    factory :work_one do
      title "An altered look about the hills --\n"
      number 140
      #image_group :igrp_one
    end

    factory :work_two do
      title "Belshazzar had a Letter --\n"
      number 1459
      #image_group :igrp_two
    end

    factory :work_three do
      title "We lose -- because we win -- "
      number 21
      #image_group :igrp_three
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
      url "http://zoom.it/oL3Y"
      #metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMDo1OTozOCAtMDQwMA==\n"
      credits "Provided by Harvard University"
    end

    factory :image_two do
      url "http://zoom.it/aoUu"
      #metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMTowMDowNSAtMDQwMA==\n"
      credits "Provided by Harvard University"
    end

    factory :image_three do
      url "http://zoom.it/c0nk"
      #metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMTowMDozOSAtMDQwMA==\n"
      credits "Provided by Harvard University"
    end

    factory :image_four do
      url "http://zoom.it/WJnR"
      #metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMDo1OTo0OSAtMDQwMA==\n"
      credits "Provided by Harvard University"
    end

    factory :image_five do
      url "http://zoom.it/2wzu"
      #metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMDo1OTo1MCAtMDQwMA==\n"
      credits "Provided by Harvard University"
    end
  end

  factory :image_group do 
    factory :igrp_harvard do
      name "Harvard Collection"
      parent_group nil
      metadata {{ "Library" => "Houghton" }}
      edition nil
      type "Collection"
      position nil
    end

    factory :igrp_one do
      name "An altered look about the hills --\n"
      #parent_group :igrp_harvard
      metadata nil
      type nil
      position 1
    end

    factory :igrp_two do
      name "Belshazzar had a Letter --\n"
      #parent_group :igrp_harvard
      metadata nil
      type nil
      position 2
    end

    factory :igrp_three do
      name "The face I carry with me -- last --\n"
      #parent_group :igrp_harvard
      metadata nil
      type nil
      position 3
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
      #work :work_one
      #image_group_image :igi_one
    end

    factory :page_two do
      #work :work_one
      #image_group_image :igi_two
    end

    factory :page_three do
      #work :work_one
      #image_group_image :igi_three
    end

    factory :page_four do
      #work :work_two
      #image_group_image :igi_four
    end

    factory :page_five do
      #work :work_two
      #image_group_image :igi_five
    end

    factory :page_six do
      #work :work_three
      #image_group_image :igi_six
    end
  end
end


