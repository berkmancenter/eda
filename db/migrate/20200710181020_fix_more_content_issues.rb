class FixMoreContentIssues < ActiveRecord::Migration[5.2]
  def change
    # F124A “Safe in their alabaster chambers” displays as Image not available:
    # http://qa.edickinson.org/editions/1/image_sets/898664
    # This should be the Springfield Republican printed version.
    work = Work.where(number: 124, variant: 'A').first
    current_work_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_work_image_set_image = current_work_image_set.image
    current_work_image_set_image.url = 'F124A_The_Sleeping_7268_1862Mar1_0001'
    current_work_image_set_image.save

    # F1715A:”A word made flesh is seldom”  still displays as Image Not Available.
    work = Work.where(number: 1715, variant: 'A').first
    first_image = Image.create(
      url: 'F1715A_p1'
    )
    second_image = Image.create(
      url: 'F1715A_p2'
    )
    work_image_set = work.image_set
    current_first_1715_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_first_1715_image_set.image = first_image
    current_first_1715_image_set.save
    second_1715_image_set = current_first_1715_image_set.duplicate
    second_1715_image_set.image = second_image
    second_1715_image_set.save
    second_1715_image_set.move_right
    work_image_set << first_image
    work_image_set << second_image

    # The p. 1 image contains some additional poems now displaying as Image Not Available:
    # F1713A "With sweetness unabashed" : http://qa.edickinson.org/editions/1/image_sets/11529006
    # F1714A, J1669 "In snow thou comest" : http://qa.edickinson.org/editions/1/image_sets/11529008
    # F1715A:”A word made flesh is seldom”  still displays as Image Not Available.
    work = Work.where(number: 1713, variant: 'A').first
    first_image = Image.create(
      url: 'F1715A_p1'
    )
    work_image_set = work.image_set
    current_first_1713_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_first_1713_image_set.image = first_image
    current_first_1713_image_set.save
    work_image_set << first_image
    work = Work.where(number: 1714, variant: 'A').first
    first_image = Image.create(
      url: 'F1715A_p1'
    )
    work_image_set = work.image_set
    current_first_1714_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_first_1714_image_set.image = first_image
    current_first_1714_image_set.save
    work_image_set << first_image
  end
end
