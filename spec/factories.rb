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
      title "An altered look about the hills"
      number 140
    end

    edition
  end

  factory :image do
    factory :image_one do
      url "http://zoom.it/oL3Y"
      metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMDo1OTozOCAtMDQwMA==\n"
      credits "Scanned by Harvard University"
    end

    factory :image_two do
      url "http://zoom.it/aoUu"
      metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMTowMDowNSAtMDQwMA==\n"
      credits "Scanned by Harvard University"
    end

    factory :image_three do
      url "http://zoom.it/c0nk"
      metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMTowMDozOSAtMDQwMA==\n"
      credits "Scanned by Harvard University"
    end

    factory :image_four do
      url "http://zoom.it/WJnR"
      metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMDo1OTo0OSAtMDQwMA==\n"
      credits "Scanned by Harvard University"
    end

    factory :image_five do
      url "http://zoom.it/2wzu"
      metadata "---\nImported: !binary |-\n  MjAxMy0wNS0yMyAxMDo1OTo1MCAtMDQwMA==\n"
      credits "Scanned by Harvard University"
    end
  end

  factory :image_group_image do
    factory :igi_one do
      image_one
      position 1
    end

    factory :igi_two do
      image_two
      position 2
    end

    factory :igi_three do
      image_three
      position 3
    end

    factory :igi_four do
      image_three
      position 1
    end

    factory :igi_five do
      image_four
      position 2
    end

    factory :igi_six do
      image_five
      position 1
    end
  end
end


