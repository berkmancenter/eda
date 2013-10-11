class MissingAmherstImageImporter
    def import(image_directory)
        puts 'Importing Amherst Images'
        collection = Collection.find_by_name('Amherst College Library')
        pbar = ProgressBar.new('Amherst', Dir.entries(image_directory).count)
        sheet_group = ImageSet.create(name: 'Other Images')
        Naturally.sort(Dir.entries(image_directory)).each_with_index do |image_filename, i|
            pbar.inc
            next if image_filename[0] == '.'
            image_url = image_filename.match(/(.*).tif/)[1]
            metadata = {                   
                'Imported' => Time.now.to_s,
            }

            image = Image.create(
                title: "Amherst - #{image_url}",
                url: image_url,
                credits: 'Amherst credits',
                metadata: metadata
            )
            sheet_group << image
        end
        sheet_group.move_to_child_of collection
        collection.save!
    end

    def new_sheet_group(collection, doc)
        name = doc.at('identifier[type=local]').text
        is = ImageSet.find_by_name(name)
        unless is
            is = ImageSet.create!(
                name: name,
                editable: false,
                metadata: { 'Shelf Location' => doc.at('shelfLocator').text }
            )
            is.move_to_child_of collection
        end
        is
    end
end
