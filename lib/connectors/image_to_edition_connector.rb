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

#        last_image = nil
#        root_image_set = ImageSet.new(name: 'All Images')

        # TODO: Check that there are no blank pages in fascicles
        # Use Houghton order for those not ordered by Franklin
#        works_by_fascicle = Work.all.group_by{|w| w.metadata['fascicle']}
#        works_by_fascicle.each do |fascicle, works|
#            image_set = ImageSet.new(name: "Fascicle #{fascicle}")
#            image_set.move_to_child_of root_image_set
#            works.sort_by!{|w| w.metadata['fascicle_order']}
#            works.each do |work|
#                work.image_set.each do |image|
#                    next if image == last_image
#                    image_set << image
#                    last_image = image
#                end
#            end
#        end
#        Work.all.group_by{|w| w.metadata['set']}
    end
end
