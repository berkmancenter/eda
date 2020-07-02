class FixContentIssues < ActiveRecord::Migration[5.2]
  def change
    # F721A "Nature is what we see" Two images, order reversed. Should be in this order:
    # http://qa.edickinson.org/editions/1/image_sets/900550
    # http://qa.edickinson.org/editions/1/image_sets/900549
    work = Work.where(number: 721, variant: 'A').first
    work.edition.image_set.leaves_showing_work(work).first.move_right

    new_work_image_sets = {
      'F711A'    => ['ms_am_1118_3_43_0003', 'ms_am_1118_3_43_0004', 'ms_am_1118_3_44_0001'],
      'F1110A'   => ['asc-2831-5-1', 'asc-2831-6-0'],
      'F819C'    => ['asc-2831-6-0', 'asc-2831-6-1'],
      'F817B'    => ['asc-14120-7-1', 'asc-14120-8-0']
    }
    new_work_image_sets.each do |full_id, image_urls|
      replace_works_image_set(full_id, image_urls)
    end

    # F711A “I meant to have but modest needs”
    # http://qa.edickinson.org/editions/1/image_sets/900525
    # Missing image for p. 3 of poem, first line But I, grown shrewder -
    # The image is there when you Browse by Image http://qa.edickinson.org/editions/1/image_sets/9100
    work = Work.where(number: 711, variant: 'A').first
    ms_am_1118_3_44_0001_image_set = Image.find_by_url('ms_am_1118_3_44_0001').image_sets.first
    ms_am_1118_3_43_0004_image_set = work.edition.image_set.leaves_showing_work(work).first
    ms_am_1118_3_44_0001_image_set.move_to_child_of(ms_am_1118_3_43_0004_image_set.parent)
    ms_am_1118_3_44_0001_image_set.save

    # "One day is there of the series" F1110A. This links to http://qa.edickinson.org/editions/1/image_sets/900895 which is not this poem.
    # F1110A should link to Amherst #set87 http://qa.edickinson.org/editions/1/image_sets/5148 with the final stanza of the poem
    # on http://qa.edickinson.org/editions/1/image_sets/5149 The metadata label that displays above the *wrong* image seems
    # to be correct, so not sure what is going on, as the Image Sets in Browse seem to be correct.
    work = Work.where(number: 1110, variant: 'A').first
    asc_2831_5_1_image_set = Image.find_by_url('asc-2831-5-1').image_sets.first
    asc_2831_6_0_image_set = Image.find_by_url('asc-2831-6-0').image_sets.first
    current_first_1110_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_first_1110_image_set.parent.descendants.destroy_all
    asc_2831_6_0_image_set.parent = current_first_1110_image_set.parent
    asc_2831_6_0_image_set.level_order_position = :first
    asc_2831_6_0_image_set.save
    asc_2831_5_1_image_set.parent = current_first_1110_image_set.parent
    asc_2831_5_1_image_set.level_order_position = :first
    asc_2831_5_1_image_set.save

    # "The luxury to apprehend" F819C should link to http://qa.edickinson.org/editions/1/image_sets/5149; it 
    # is currently linking to the second page of the poem, http://qa.edickinson.org/editions/1/image_sets/900852
    work = Work.where(number: 819, variant: 'C').first
    current_first_819_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_first_819_image_set.parent.descendants.destroy_all
    asc_2831_6_1_image = Image.find_by_url('asc-2831-6-1')
    asc_2831_6_1_image_set = ImageSet.new
    asc_2831_6_1_image_set.image = asc_2831_6_1_image
    asc_2831_6_1_image_set.parent = current_first_819_image_set.parent
    asc_2831_6_1_image_set.level_order_position = :first
    asc_2831_6_1_image_set.save
    asc_2831_6_0_image = Image.find_by_url('asc-2831-6-0')
    asc_2831_6_0_image_set = ImageSet.new
    asc_2831_6_0_image_set.image = asc_2831_6_0_image
    asc_2831_6_0_image_set.parent = current_first_819_image_set.parent
    asc_2831_6_0_image_set.level_order_position = :first
    asc_2831_6_0_image_set.save

    # The transcriptions that display with http://qa.edickinson.org/editions/1/image_sets/900852 should be reversed.
    # As this is the second page of F819C, that should come first. F810B "The robin for the crumb",
    # which is at the bottom of the page, should come second.
    work_819_c_image_set_level_order = Work.where(number: 819, variant: 'C').first.image_set.level_order
    work_810_b_image_set = Work.where(number: 810, variant: 'B').first.image_set
    work_810_b_image_set.level_order = work_819_c_image_set_level_order + 1
    work_810_b_image_set.save

    # F817B - "This consciousness that is aware" is incorrectly linked to the image of page 2 of the poem, http://qa.edickinson.org/editions/1/image_sets/900761
    # It should link to http://qa.edickinson.org/editions/1/image_sets/6583 where it is correctly followed by http://qa.edickinson.org/editions/1/image_sets/6584
    work = Work.where(number: 817, variant: 'B').first
    asc_14120_7_1_image_set = Image.find_by_url('asc-14120-7-1').image_sets.first
    asc_14120_8_0_image_set = Image.find_by_url('asc-14120-8-0').image_sets.first
    current_first_817_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_first_817_image_set.parent.descendants.destroy_all
    asc_14120_8_0_image_set.parent = current_first_817_image_set.parent
    asc_14120_8_0_image_set.level_order_position = :first
    asc_14120_8_0_image_set.save
    asc_14120_7_1_image_set.parent = current_first_817_image_set.parent
    asc_14120_7_1_image_set.level_order_position = :first
    asc_14120_7_1_image_set.save

    # Fixing the works order in the above ^^^
    work_794_b_image_set_level_order = Work.where(number: 794, variant: 'B').first.image_set.level_order
    work_817_b_image_set = Work.where(number: 817, variant: 'B').first.image_set
    work_817_b_image_set.level_order = work_794_b_image_set_level_order - 1
    work_817_b_image_set.save

    # F817A "This consciousness that is aware" is linked to Image not found: http://qa.edickinson.org/editions/1/image_sets/900880
    # This is a Houghton manuscript, although I don't find it in the Browse.
    # The call number is MS Am 1118.7 and the text begins "Adventure most unto itself".
    # If you can't find it, I can download and send it to you.
    work = Work.where(number: 817, variant: 'A').first
    current_work_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_work_image_set_image = current_work_image_set.image
    current_work_image_set_image.url = 'F817Ap1'
    current_work_image_set_image.save

    # F124A “Safe in their alabaster chambers” displays as Image not available:
    # http://qa.edickinson.org/editions/1/image_sets/898664
    # This should be the Springfield Republican printed version.
    work = Work.where(number: 124, variant: 'A').first
    current_work_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_work_image_set_image = current_work_image_set.image
    current_work_image_set_image.url = 'F124A The Sleeping 7268_1862Mar1_0001'
    current_work_image_set_image.save
  end

  def replace_works_image_set(work_full_id, new_image_urls)
    work = Work.find_by_full_id(work_full_id)
    work.image_set.descendants.destroy_all
    new_image_urls.each do |url|
      work.image_set << Image.find_by_url(url)
    end
    work.save!
  end
end
