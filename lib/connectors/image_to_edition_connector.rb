class ImageToEditionConnector
    def connect
        pbar = ProgressBar.new("Connecting", Collection.count * Edition.count)
        Collection.all.each do |collection|
            Edition.all.each do |edition|
                old_image_set = edition.image_set
                edition.image_set = old_image_set.duplicate
                edition.save!
                old_image_set.destroy
                duplicate = collection.duplicate
                duplicate.move_to_child_of edition.image_set
                pbar.inc
            end
        end
    end
end
