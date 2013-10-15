class AmherstImageImporter
    def import(image_directory, mods_directory, mets_directory)
        puts 'Importing Amherst Images'
        collection = Collection.create(name: 'Amherst College')
        collection.metadata = {
            'URL' => 'https://acdc.amherst.edu/browse/collection/collection:ed',
            'Long Name' => 'Amherst College, Amherst MA',
            'Code' => 'A,ACL'
        }
        last_accession_number = ''
        sheet_group = collection
        pbar = ProgressBar.new('Amherst', Dir.entries(image_directory).count)
        Naturally.sort(Dir.entries(image_directory)).each_with_index do |image_filename, i|
            pbar.inc
            next if image_filename[0] == '.'
            accession_number = image_filename.match(/asc-\d+/)[0].sub('-', ':')
            mods_filename = mods_directory + '/' + accession_number + '/MODS.xml'
            doc = Nokogiri::XML(File.open(mods_filename))
            doc.remove_namespaces!
            if accession_number != last_accession_number
                sheet_group = new_sheet_group(collection, doc)
            end
            last_accession_number = accession_number
            image_url = image_filename.match(/(.*).tif/)[1]
            metadata = {                   
                'Imported' => Time.now.to_s,
                'Identifiers' => doc.css('identifier[type=local]').map(&:text),
                'Shelf Location' => doc.at('shelfLocator').text,
                'Title' => doc.at('title').text,
                'Amherst Location' => doc.css('identifier[type=uri]').text
            }
            mets_metadata(image_filename)
            next

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

    def parse_image_filename(image_filename)
        pattern = /^asc-(?<asc>\d+)-(?<page>\d+)(-(?<subpage>0|1))?\.tif$/
        image_filename.match(pattern).named_captures
    end

    def find_mods_file(image_filename)
        <fedora:isPartOf rdf:resource="info:fedora/asc:17270"></fedora:isPartOf>
        <amherst:hasPageNumber>11</amherst:hasPageNumber>
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
