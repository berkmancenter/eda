FactoryGirl.define do
  factory :edition do
    factory :johnson do
      name "The Poems of Emily Dickinson"
      short_name 'Johnson Edition'
      author "Thomas H. Johnson"
      date "1951-01-01"
      work_number_prefix "J"
      completeness 0.95
      public true
    end

    factory :franklin do
      name "The Poems of Emily Dickinson: Variorum Edition"
      short_name 'Franklin Edition'
      author "R. W. Franklin"
      date "1998-01-01"
      work_number_prefix "F"
      completeness 1
      public true
    end

    factory :tested do
      name 'Test Edition'
      short_name 'Test Edition'
      author 'Ryan Westphal'
      date '2013-06-06'
      work_number_prefix 'T'
      completeness 0.1
      public true
    end
  end

  factory :work_set do
    factory :wset_johnson do
      name 'Works in Johnson Edition'
      editable true
    end

    factory :wset_franklin do
      name 'Works in Franklin Edition'
      editable true
    end

    factory :wset_tested do
      name 'Works in Test Edition'
      editable true
    end
  end

  factory :work do
    #edition :johnson

    #edition :franklin

    factory :work_f1a do
      title 'Awake ye muses nine, sing me a strain divine'
      number 1
      variant 'A'
      date '1850-01-01'
    end

    factory :work_f2a do
      title 'Sic transit gloria mundi'
      number 2
      variant 'A'
    end

    factory :work_f2b do
      title 'Sic transit gloria mundi'
      number 2
      variant 'B'
    end

    factory :work_f3a do
      title 'On this wondrous sea'
      number 3
      variant 'A'
    end

    factory :work_f3b do
      title 'On this wondrous sea'
      number 3
      variant 'B'
    end

    factory :work_variant do
      title "Sic transit gloria mundi"
      date "1852-01-01"
      number 2
      variant "B"
    end

    factory :work_f131a do
      title 'Besides the Autumn poets sing'
      number 131
      variant 'A'
    end

    #edition :tested

    factory :tw_no_stanzas do
      title 'no_stanzas'
      number 1
    end


  end

  factory :stanza do
    factory :z_f1a0 do
      #work :work_f1a
      position 0
    end

    factory :z_f131a0 do
      #work :work_f131a
      position 0
    end
  end

  factory :line do
    # f1a
    factory :l_f1a01 do
      text 'Awake ye muses nine, sing me a strain divine,'
      number 1
    end

    factory :l_f1a02 do
      text 'unwind the solemn twine, and tie my Valentine!'
      number 2
    end

    factory :l_f1a03 do
      text '        --- --- ---'
      number 3
    end

    factory :l_f1a04 do
      text 'Oh the Earth was <i>made</i> for lovers, for damsel, and hopeless swain,'
      number 4
    end

    factory :l_f1a05 do
      text 'for sighing, and gentle whispering, and <i>unity</i> made of <i>twain,</i>'
      number 5
    end

    factory :l_f1a06 do
      text 'all things do go a courting, in earth, or sea, or air,'
      number 6
    end

    factory :l_f1a07 do
      text 'God hath made nothing single but <i>thee</i> in his world so fair!'
      number 7
    end

    # f131a
    factory :l_f131a01 do
      text 'Besides the Autumn poets sing'
      number 1
    end
  end

  factory :division do
    factory :d_f1a03 do
      type 'Division'
      subtype 'page_or_column'
      #work :work_f1a
      start_line_number 3
      start_address 19
      end_line_number 3
      end_address 19
      original_characters '---'
    end

    factory :d_f1a06 do
      type 'Division'
      subtype 'page_or_column'
      #work :work_f1a
      start_line_number 6
      start_address 54
      end_line_number 6
      end_address 54
      original_characters 'air,'
    end
  end

  # metadata is not designed enough to test
  factory :image do
    factory :image_one do
      url 'ms_am_1118_10_10_0001'
      title 'p. 2, Your - Riches - taught me - poverty! , L258, J299, Fr418'
      metadata {{
        'Imported' => '2013-07-11 12:00:00 -0400',
        'Order' => '2',
        'Order Label' => '',
        'Label' => 'p. 2, Your - Riches - taught me - poverty! , L258, J299, Fr418'
      }}
      credits 'This material is owned, held, or licensed by the President and Fellows of Harvard College. It is being provided solely for the purpose of teaching or individual research. Any other use, including commercial reuse, mounting on other systems, or other forms of redistribution requires permission of the appropriate office of Harvard University.'
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

  factory :collection do
    factory :iset_harvard do
      name 'Harvard Collection'
      #parent nil
      metadata {{ "Library" => "Houghton" }}
      type 'Collection'
    end
  end

  factory :image_set do 
    factory :iset_johnson do
      name 'Images for Johnson Edition'
      editable true
    end

    factory :iset_franklin do
      name 'Images for Franklin Edition'
      editable true
    end

    # visually, the following image_sets look like this, where the numbers are work numbers and the blocks are scanned images
    #
    # 11111 11111 11111 22222 33333
    # 11111 11111       22222 33333
    # 11111 11111 22222       33333
    # 11111 11111 22222
    #
      
    # an image set contains all the images for a poem and their order
    factory :iset_one do
      name 'Awake ye muses nine, sing me a strain divine'
      #parent :iset_franklin
      metadata nil
      editable false
    end

    factory :iset_two do
      name 'Sic transit gloria mundi'
      #parent :iset_franklin
      metadata nil
      editable false
    end

    factory :iset_three do
      name 'On this wondrous sea'
      #parent :iset_franklin
      metadata nil
      editable false
    end

    factory :iset_four do
      name 'Besides the Autumn poets sing'
      #parent :iset_franklin
      metadata nil
      editable false
    end

    factory :iset_tested do
      name 'Images for Test Edition'
      editable true
    end

    factory :iset_no_stanzas do
      name 'no_stanzas'
      #parent :iset_tested
      metadata nil
      editable false
    end
  end

  factory :word do
    factory :awake do
      word 'awake'
    end
  end

  factory :word_variant do
    factory :awake_adj do
      #word awake
      endings ''
      part_of_speech 'adj'
      etymology ''
    end
  end

  factory :definition do
    factory :awake_one do
      #word_variant awake_adj
      number 1
      definition 'Fully conscious; totally aware; not dreaming; [fig.] fixed in a permanent state; not in a temporary state.'
    end

    factory :awake_two do
      #word_variant awake_adj
      number 2
      definition 'Living; physically functioning.'
    end
  end
end


