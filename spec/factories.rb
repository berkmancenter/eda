FactoryGirl.define do
  factory :edition do
    name "The Poems of Emily Dickinson"
    author "Thomas H. Johnson"
    date "1951-01-01"
    work_number_prefix "J"
    completeness 0.95
  end

  factory :work do
    title "An altered look about the hills"
    number 140

    factory :work_with_edition do
      edition
    end

  end

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

end


