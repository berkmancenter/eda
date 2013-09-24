class ImageToEditionConnector
    def connect
        pbar = ProgressBar.new("Connecting", Collection.count * Edition.count)
        Edition.all.each do |edition|
            old_image_set = edition.image_set
            edition.image_set = old_image_set.duplicate
            edition.save!
            Collection.all.each do |collection|
                dup = collection.duplicate
                dup = dup.becomes(ImageSet)
                dup.update_column(:parent_id, edition.image_set.id)
                dup.update_column(:type, 'ImageSet')
                #dup.self_and_descendants.each{|n| n.update_column(:depth, n.depth + 1)}
                dup.save!
                pbar.inc
            end
            edition.image_set.update_column(:rgt, Sett.maximum('rgt') + 1)
            edition.save!
        end
    end
end
