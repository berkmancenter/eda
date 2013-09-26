class SingleHoundImporter
    ID_PATTERN = /^SH(?<numeral>[IVXLCM]+)\.(?<number>[i0-9]+)$/
    def import(filename)
        puts "Importing Single Hound"
        edition = create_edition

        doc = Nokogiri::XML(File.open(filename), nil, nil, Nokogiri::XML::ParseOptions::RECOVER)
        pbar = ProgressBar.new("Single Hound", doc.css('div').count)
        doc.css('div').each do |poem|
            work = edition.works.new(number: pull_number(poem))
            work.metadata['Page'] = pull_page(poem)
            poem.css('lg').each_with_index do |lg, i|
                stanza = work.stanzas.new(position: i + 1)
                lg.css('l').each_with_index do |l, j|
                    line = stanza.lines.new(text: l.text.strip, number: j + 1)
                end
            end
            pbar.inc
        end
        edition.save!
    end

    def pull_number(poem)
        match = poem['xml:id'].match(ID_PATTERN)
        if match && match[:numeral]
        output = RomanNumerals.to_decimal(match[:numeral]) 
        else
            output = 0
        end
        output
    end

    def pull_page(poem)
        match = poem['xml:id'].match(ID_PATTERN)
        match[:number] if match
    end

    def create_edition
        edition = Edition.new(
            :name => 'The Single Hound,  Bianchi, 1914',
            :short_name => 'Single Hound 1914',
            :citation => 'The Single Hound,  Martha Dickinson Bianchi, Boston: Little Brown, 1914',
            :author => 'Martha Dickinson Bianchi',
            :date => Date.new(1914, 1, 1),
            :work_number_prefix => 'SH14-',
            :completeness => 0.4,
            :public => true
        )
        edition.create_image_set(
            :name => "Images for #{edition.name}",
            :editable => true,
        )
        edition.create_work_set(
            name: "Works in #{edition.name}",
            editable: true
        )
        edition
    end
end
