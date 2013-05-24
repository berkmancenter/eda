# TODO: image_group

FactoryGirl.define do
  factory :edition do
    name "The Poems of Emily Dickinson"
    author "Thomas H. Johnson"
    date "1951-01-01"
    work_number_prefix "J"
    completeness 0.95
  end

  factory :work do
    factory :work_one do
      title "An altered look about the hills --\n"
      number 140
    end

    factory :work_two do
      title "Belshazzar had a Letter --\n"
      number 1459
    end

    factory :work_three do
      title "The face I carry with me -- last --\n"
      number 336
    end

    factory :work_variant do
      title "Sic transit gloria mundi"
      date "1852-01-01"
      number 2
      variant "[<i>B</i>]"
    end

    edition
  end

  factory :image do
    url "http://zoom.it/oL3Y"
    metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMDo1OTozOCAtMDQwMA==\n"
    credits "Provided by Harvard University"

    factory :image_one do
      url "http://zoom.it/oL3Y"
      metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMDo1OTozOCAtMDQwMA==\n"
      credits "Provided by Harvard University"
    end

    factory :image_two do
      url "http://zoom.it/aoUu"
      metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMTowMDowNSAtMDQwMA==\n"
      credits "Provided by Harvard University"
    end

    factory :image_three do
      url "http://zoom.it/c0nk"
      metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMTowMDozOSAtMDQwMA==\n"
      credits "Provided by Harvard University"
    end

    factory :image_four do
      url "http://zoom.it/WJnR"
      metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMDo1OTo0OSAtMDQwMA==\n"
      credits "Provided by Harvard University"
    end

    factory :image_five do
      url "http://zoom.it/2wzu"
      metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMDo1OTo1MCAtMDQwMA==\n"
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
      parent_group :factory => :igrp_harvard
      metadata nil
      type nil
      position 1
    end

    factory :igrp_two do
      name "Belshazzar had a Letter --\n"
      parent_group :factory => :igrp_harvard
      metadata nil
      type nil
      position 2
    end

    factory :igrp_three do
      name "The face I carry with me -- last --\n"
      parent_group :factory => :igrp_harvard
      metadata nil
      type nil
      position 3
    end
  end

  factory :image_group_image do
    factory :igi_one do
      image_group :factory => :igrp_one
      image :factory => :image_one
      position 1
    end

    factory :igi_two do
      image_group :factory => :igrp_one
      image :factory => :image_two
      position 2
    end

    factory :igi_three do
      image_group :factory => :igrp_one
      image :factory => :image_three
      position 3
    end

    factory :igi_four do
      image_group :factory => :igrp_two
      image :factory => :image_three
      position 1
    end

    factory :igi_five do
      image_group :factory => :igrp_two
      image :factory => :image_four
      position 2
    end

    factory :igi_six do
      image_group :factory => :igrp_three
      image :factory => :image_five
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
    factory :page_one do
      work :factory => :work_one
      image_group_image :factory => :igi_one
    end

    factory :page_two do
      work :factory => :work_one
      image_group_image :factory => :igi_two
    end

    factory :page_three do
      work :factory => :work_one
      image_group_image :factory => :igi_three
    end

    factory :page_four do
      work :factory => :work_two
      image_group_image :factory => :igi_four
    end

    factory :page_five do
      work :factory => :work_two
      image_group_image :factory => :igi_five
    end

    factory :page_six do
      work :factory => :work_three
      image_group_image :factory => :igi_six
    end
  end
end


