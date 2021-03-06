class ImageToEditionConnector
    def connect_straight
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

    def connect_by_image
        root_image_set = ImageSet.create(name: 'All Images')
        added_images = []

        images_by_fascicle = Image.all.group_by{|w| w.metadata['fascicle']}
        fascicles = images_by_fascicle.keys.compact.sort
        pbar = ProgressBar.new("Connecting", images_by_fascicle.keys.count)
        fascicles.each do |fascicle|
            images = images_by_fascicle[fascicle]
            image_set = ImageSet.create(name: "Fascicle #{fascicle}")
            image_set.move_to_child_of root_image_set
            images.sort_by!{|w| w.metadata['fascicle_order']}
            images.each do |image|
                image_set << image
                added_images << image.id
            end
            pbar.inc
        end

        images_by_set = Work.all.group_by{|w| w.metadata['set']}
        sets = images_by_set.keys.compact.sort
        pbar = ProgressBar.new("Connecting", images_by_set.keys.count)
        sets.each do |set|
            images = images_by_set[set]
            image_set = ImageSet.create(name: "Set #{set}")
            image_set.move_to_child_of root_image_set
            images.sort_by!{|w| w.metadata['set_order']}
            images.each do |image|
                image_set << image
                added_images << image.id
            end
            pbar.inc
        end

        pbar = ProgressBar.new("Connecting", Image.count)
        misc_image_set = ImageSet.create(name: 'Other Images')
        Collection.all.each do |collection|
            dup_collection = collection.duplicate
            dup_collection.leaves.each do |leaf|
                if leaf.image && added_images.include?(leaf.image.id)
                    leaf.destroy
                end
                pbar.inc
            end
            dup_collection.move_to_child_of misc_image_set
            misc_image_set.save!
        end
        misc_image_set.move_to_child_of root_image_set

        Edition.all.each do |edition|
            edition.image_set = root_image_set.duplicate
            edition.save!
        end
    end

    def connect
        last_image = nil
        root_image_set = ImageSet.create(name: 'All Images')
        added_images = []

       # TODO: Check that there are no blank pages in fascicles
       # Use Houghton order for those not ordered by Franklin
        works_by_fascicle = Work.all.group_by{|w| w.metadata['fascicle']}
        fascicles = works_by_fascicle.keys.compact.sort
        pbar = ProgressBar.new("Connecting", works_by_fascicle.keys.count)
        fascicles.each do |fascicle|
            works = works_by_fascicle[fascicle]
            image_set = ImageSet.create(name: "Fascicle #{fascicle}")
            image_set.move_to_child_of root_image_set
            works.sort_by!{|w| w.metadata['fascicle_order']}
            works.each do |work|
                work.image_set.all_images.each do |image|
                    # Don't add an image more than once (assumes in correct order)
                    next if image == last_image
                    image_set << image
                    added_images << image.id
                    next_image = nil
                    # Attempt to include blank backs of pages
                    next_image_set = work.image_set.leaf_after(work.image_set.leaves_containing(image).first)
                    next_image = next_image_set.image if next_image_set
                    if next_image && Work.in_image(next_image).empty?
                        image_set << next_image
                        added_images << next_image.id
                        last_image = next_image
                    else
                        last_image = image
                    end
                end
            end
            pbar.inc
        end

        works_by_set = Work.all.group_by{|w| w.metadata['set']}
        sets = works_by_set.keys.compact.sort
        pbar = ProgressBar.new("Connecting", works_by_set.keys.count)
        sets.each do |set|
            works = works_by_set[set]
            image_set = ImageSet.create(name: "Set #{set}")
            image_set.move_to_child_of root_image_set
            works.each do |work|
                work.image_set.all_images.each do |image|
                    # Don't add an image more than once (assumes in correct order)
                    next if image == last_image
                    image_set << image
                    added_images << image.id
                    next_image = nil
                    # Attempt to include blank backs of pages
                    next_image_set = work.image_set.leaf_after(work.image_set.leaves_containing(image).first)
                    next_image = next_image_set.image if next_image_set
                    if next_image && Work.in_image(next_image).empty?
                        next_image = work.image_set.leaf_after(work.image_set.leaf_containing(image)).image
                        added_images << next_image.id
                        last_image = next_image
                    else
                        last_image = image
                    end
                end
            end
            pbar.inc
        end

        pbar = ProgressBar.new("Connecting", Image.count)
        misc_image_set = ImageSet.create(name: 'Other Images')
        Collection.all.each do |collection|
            dup_collection = collection.duplicate
            dup_collection.leaves.each do |leaf|
                if leaf.image && added_images.include?(leaf.image.id)
                    leaf.destroy
                end
                pbar.inc
            end
            dup_collection.move_to_child_of misc_image_set
            misc_image_set.save!
        end
        misc_image_set.move_to_child_of root_image_set

        Edition.all.each do |edition|
            edition.image_set = root_image_set.duplicate
            edition.save!
        end
    end
end
