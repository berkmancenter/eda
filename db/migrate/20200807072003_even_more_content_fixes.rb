class EvenMoreContentFixes < ActiveRecord::Migration[5.2]
  def change
    # F1110A One day is there of the series links to the final stanza of the poem at
    # http://qa.edickinson.org/editions/1/image_sets/12202623 It should link to
    # http://qa.edickinson.org/editions/1/image_sets/5148 and then be followed
    # by the page with the final stanza
    work = Work.where(number: 1110, variant: 'A').first
    asc_2831_5_1_image_set = Image.find_by_url('asc-2831-5-1').image_sets.first
    asc_2831_6_0_image_set = Image.find_by_url('asc-2831-6-0').image_sets.first
    current_first_1110_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_first_1110_image_set.parent.descendants.destroy_all
    asc_2831_5_1_image_set.move_to_child_of(current_first_1110_image_set.parent)
    asc_2831_5_1_image_set.save
    asc_2831_6_0_image_set.move_to_child_of(current_first_1110_image_set.parent)
    asc_2831_6_0_image_set.save

    # F817A "This consciousness that is aware" is linked correctly, but the
    # verso (with address "Sue") doesn't display. I think this is because
    # there's no option box to switch from Edition to Library (and hence Reading View).
    # The image sent was labeled F817Ap2. When I try using the right
    # arrow, I get an error message.
    work = Work.where(number: 817, variant: 'A').first
    first_image = Image.create(
      url: 'F817Ap2'
    )
    current_work_image_set = work.edition.image_set.leaves_showing_work(work).first
    f_817p2_image_set = current_work_image_set.duplicate
    f_817p2_image_set.image = first_image
    f_817p2_image_set.move_to_child_of(current_work_image_set.parent)
    f_817p2_image_set.save
  end
end
