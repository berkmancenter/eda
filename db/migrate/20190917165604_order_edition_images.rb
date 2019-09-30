class OrderEditionImages < ActiveRecord::Migration
  def up
    edition_to_old_image_set_id = {}
    begin
      num_editions = Edition.is_public.count
      Edition.is_public.each_with_index do |edition, i|
        puts "Updating edition #{i+1} of #{num_editions}, ID #{edition.id}"
        edition_to_old_image_set_id[edition.id] = EditionImageSorter.sort(edition)
      end
    ensure
      # We don't remove the old image sets from the database so we can recover
      # if needed. Disk space is cheap.
      # Save the old edition-id-to-image-set-id map to disk
      filename = Rails.root.join('tmp', "edition_to_old_image_set_id_#{DateTime.now.to_s}.json")
      JSON.dump(edition_to_old_image_set_id, File.open(filename, 'w'))
    end
  end

  def down
    backup_dir = Rails.root.join('tmp', 'edition_to_old_image_set_id*.json')
    most_recent_id_map_file = Dir.glob(backup_dir).sort.last
    edition_to_image_set_id = JSON.load(File.open(most_recent_id_map_file))
    edition_to_image_set_id.each do |edition_id, image_set_id|
      edition = Edition.find(edition_id)
      edition.image_set_id = image_set_id
      edition.save!
    end
    File.delete(most_recent_id_map_file)
  end
end
