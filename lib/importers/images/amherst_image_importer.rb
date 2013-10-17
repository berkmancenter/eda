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
            metadata = metadata.merge(mets_metadata(image_filename, mets_directory))

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

    def mets_metadata(image_filename, mets_directory)
        mets_filename = find_mods_file(image_filename, mets_directory)
        metadata = {}
        doc = Nokogiri::XML::Document.parse(File.join(mets_directory, mets_filename), nil, nil, Nokogiri::XML::ParseOptions::RECOVER)
        doc.css('dc:title').each{ |n| metadata['Title'] = n.text }
        doc.css('dc:identifier').each{ |n| metadata['Accession Number'] = n.text }
        doc.css('amherst:hasPageNumber').each{ |n| metadata['Page'] = n.text }
        metadata
    end

    def parse_image_filename(image_filename)
        pattern = /^asc-(?<asc>\d+)-(?<page>\d+)(-(?<subpage>0|1))?\.tif$/
        image_filename.match(pattern)
    end

    def parse_mets_filename(filename)
        pattern = /asc:(?<asc>\d+)\.xml/
        filename.match(pattern)
    end
                        
    def find_mods_file(image_filename, mets_directory)
        possible_files = []
        image_filename_parts = parse_image_filename(image_filename)
        manuscript_asc = image_filename_parts[:asc]
        page_number = image_filename_parts[:page]
        man_asc_pattern = %Q|<fedora:isPartOf rdf:resource="info:fedora/asc:#{manuscript_asc}"></fedora:isPartOf>|
        page_number_pattern = "<amherst:hasPageNumber>#{page_number}</amherst:hasPageNumber>"
        Naturally.sort(Dir.entries(mets_directory)).find do |filename|
            full_filename = File.join(mets_directory, filename)
            filename_parts = parse_mets_filename(filename)
            next unless File.file?(full_filename)
            next unless filename_parts[:asc].to_i >= manuscript_asc.to_i && filename_parts[:asc].to_i < manuscript_asc.to_i + 100
            file_text = File.read(full_filename)
            file_text.match(man_asc_pattern) && file_text.match(page_number_pattern)
        end
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
