class AmherstImageImporter
    def import(image_directory, mods_directory)
        puts 'Importing Amherst Images'
        collection = Collection.create(name: 'Amherst College Library')
        collection.metadata = {
            'URL' => 'https://www.amherst.edu/library/archives/holdings/edickinson',
            'Long Name' => 'Amherst College Library, Amherst MA',
            'Code' => 'A,ACL'
        }
        last_call_number = ''
        sheet_group = collection
        pbar = ProgressBar.new('Amherst', Dir.entries(image_directory).count)
        Naturally.sort(Dir.entries(image_directory)).each_with_index do |image_filename, i|
            pbar.inc
            next if image_filename[0] == '.'
            call_number = image_filename.match(/asc-\d+/)[0].sub('-', ':')
            mods_filename = mods_directory + '/' + call_number + '/MODS.xml'
            doc = Nokogiri::XML(File.open(mods_filename))
            doc.remove_namespaces!
            if call_number != last_call_number
                sheet_group = new_sheet_group(collection, doc)
            end
            last_call_number = call_number
            image_url = image_filename.match(/(.*).tif/)[1]
            metadata = {                   
                'Imported' => Time.now.to_s,
                'Identifiers' => doc.css('identifier[type=local]').map(&:text),
                'Shelf Location' => doc.at('shelfLocator').text,
                'Title' => doc.at('title').text,
                'Amherst Location' => doc.css('identifier[type=uri]').text
            }

            image = Image.create(
                title: "Amherst - #{metadata['Identifiers'].find{|i| i.include?('Amherst')}} - #{metadata['Title']}",
                url: image_url,
                credits: 'Amherst credits',
                metadata: metadata
            )
            sheet_group << image
        end
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
