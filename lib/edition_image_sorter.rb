module EditionImageSorter
  def self.sort(edition_id)
    edition = Edition.find(edition_id)
    old_image_set_id = edition.image_set_id

    pbar = ProgressBar.create(title: 'Sorting images',
                              total: edition.works.count,
                              format: '%t: |%B| %c/%C (%P%) %a -%E ')

    set = ImageSet.create(name: edition.short_name)
    edition.works.order(:number, :variant).each_with_index do |work, i|
      work_set = ImageSet.new(name: work.full_id)
      work_set.parent = set
      work_set.level_order_position = i
      work_set.save!
      work.image_set.all_images.each do |image|
        work_set << image
      end
      pbar.increment
    end
    set.save!
    edition.image_set = set
    edition.save!
    return old_image_set_id
  end
end
