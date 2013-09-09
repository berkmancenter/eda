class ImageToEditionConnector
    def connect
        Collection.all.each do |collection|
            Edition.all.each do |edition|
                duplicate = collection.duplicate
                duplicate.move_to_child_of edition.image_set
            end
        end
    end
end
