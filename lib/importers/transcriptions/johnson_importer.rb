class JohnsonImporter
    REVISION_PATTERN = /(\d+)\.?([^\]]*)]([^0-9]*)(\s{2,}|$)/
    def import(filename, max_poems = nil)
        puts "Importing Johnson works"
        edition = Edition.new(
            :name => 'The Poems of Emily Dickinson',
            :author => 'Thomas H. Johnson',
            :date => Date.new(1951, 1, 1),
            :work_number_prefix => 'J',
            :completeness => 0.95,
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

        text = File.readlines(filename)
        text = delete_page_numbers(text)
        poems = turn_into_xml(text.join)
        #File.write(Rails.root.join('tmp', 'johnson.xml'), poems)
        doc = Nokogiri::XML::Document.parse(poems, nil, nil, Nokogiri::XML::ParseOptions::RECOVER)
        pbar = ProgressBar.new("Johnson", doc.css('poem').count)
        max_poems = doc.css('poem').count unless max_poems
        doc.css('poem').each_with_index do |poem, i|
            pbar.inc
            next if i >= max_poems
            content = poem.css('body').map{|n| n.content}.join('').strip.gsub(REVISION_PATTERN, '')
            work = Work.new(:number => poem.css('number').text, :title => content.lines.first)
            stanza = Stanza.new(:position => 0)
            stanza_count = 0
            line_number = 0
            content.lines.each do |line|
                if line == "\n"
                    work.stanzas << stanza
                    stanza_count += 1
                    stanza = Stanza.new(:position => stanza_count)
                else
                    line_number += 1
                    stanza.lines << Line.new(:text => line.strip, :number => line_number)
                end
            end
            work.stanzas << stanza
            appearances = build_work_appearances(poem)
            manuscript_metadata = manuscript_metadata(poem)
            if manuscript_metadata
                work.date = Date.new(manuscript_metadata['Year'], 1, 1) if manuscript_metadata['Year']
                work.metadata = manuscript_metadata
            end
            work.metadata['Manuscript'] = poem.at('manuscript').text if poem.at('manuscript')
            work.metadata['Publication'] = poem.at('publication').text if poem.at('publication')
            work.appearances = appearances unless appearances.nil?
            work.revisions = modifiers_from_body(poem)
            work.save!
            edition.works << work
        end
        edition.save!
        locate_revisions!(edition)
    end

    def delete_page_numbers(text)
        text.delete_if { |line| line.match /^\s*\[\s*\d*\s*\]\s*$/ }
    end

    def turn_into_xml(text)
        number_pattern = /^\s*(\d+)\s*$/ 
        manuscript_pattern = /^\s*(Manuscripts?|No autograph|This.*poem|These lines|No manuscript|This scrap of verse|No copy of the version|This Poem|These unpublished stanzas|There is no autograph|Martha D. Bianchi presented)/
        publication_pattern = /^\s*Publication(:| Poems| SH| BM)/
        text = text.gsub(number_pattern, "</publication>\n\n<number>\\1</number>\n<body>\n") \
            .sub("</publication>\n\n<number>1914</number>\n<body>\n",'') \
            .gsub(manuscript_pattern, "\n</body>\n<manuscript>\\0").gsub(publication_pattern, "</manuscript>\n\n<publication>\n\\0") \
            .sub("</publication>\n\n<number>227</number>", "</manuscript>\n\n<number>227</number>") \
            .gsub(/(<\/body>\n<manuscript>[^<]*)<\/body>\n<manuscript>/m, '\1') \
            .gsub(/(<publication>[^<]*)<\/body>\n<manuscript>/m, '\1') \
            .gsub(/(<manuscript>[^<]*)<\/publication>/m, '\1</manuscript>') \
            .gsub('<number>', "</poem>\n<poem>\n<number>").gsub("\n\n\n", "\n\n").gsub(/\n*\s*\[no stanza break\]\s*\n*/, "\n") \
            .sub('</publication>', '').sub('</poem>', '') + '</manuscript></poem>'
        '<poems>' + text + '</poems>'
    end

    def modifiers_from_body(poem)
        revisions = []
        suspicious = []
        mods = poem.at('body').content.scan(REVISION_PATTERN).map do |a|
            a.delete_at(-1)
            a.map!{|v| v.strip}
            a[0] = a.first.to_i
            a
        end
        suspicious = mods.select{|a| a.any?{|v| v.to_s =~ /(\s{2,}|\n|-+\s?\d|\[|\])/}}
        puts poem.at('number').text + ":\n" + suspicious.map{|a| a.inspect + "\n"}.join + "\n" unless suspicious.empty?
        (mods - suspicious).each do |modifier|
            start_address = modifier[1] == '' ? 0 : nil
            new_chars = modifier[2].split('/').map(&:strip)
            new_chars.each do |new_char|
                revisions << Revision.new(
                    :start_line_number => modifier.first,
                    :end_line_number => modifier.first,
                    :original_characters => modifier[1],
                    :new_characters => new_char,
                    :start_address => start_address
                )
            end
        end
        revisions
    end

    def manuscript_metadata(poem)
        metadata = {}
        year_match = poem.at('manuscript').content.match(/18\d\d/)
        year = year_match[0].to_i if year_match
        metadata['Year'] = year if year && year >= 1850 && year <= 1886 
        codes = {
            'AAS'      => 'The American Anitquarian Society, Worchester, Mass.',
            'Bingham'  => 'Millicent Todd Bingham',
            'BPL Higg' => 'The Thomas Wentworth Higginson papers in the Galatea Collection, Boston Public Library',
            'H'        => 'The Dickinson Collection in the Houghton Library, Harvard University Library',
            'H B'      => 'Manuscripts which had special association for Mrs. Bianchi',
            'H H'      => 'Manuscripts presented to Harvard by descendants of Dr. and Mrs. Josiah Gilbert Holland',
            'H Higg'   => 'Manuscripts presented by Thomas Wentworth Higginson of his heirs',
            'H L'      => 'Letters formerly in the possession of Lavinia Norcross Dickinson or Susan Gilbert Dickinson or their heirs',
            'H SH'     => "Holographs in Mrs. Bianchi's own copy of The Single Hound",
            'H ST'     => 'Transcripts of Emily Dickinson poems made by Susan Gilbert Dickinson',
            'TT'       => 'Transcripts of Emily Dickinson poems made by Mabel Loomis Todd and now in the possesion of her daughter, Millicent Todd Bingham'
        }
        pattern = Regexp.new("About (\\d{4}), in packet ([-0-9]+) \\((#{codes.keys.join('|')}) ([-0-9a-z]*)\\)")
        matches = poem.at('manuscript').content.match(pattern)
        return metadata if matches.nil?
        year = matches[1].to_i if matches[1].to_i > 0
        packet = matches[2]
        code = matches[3]
        code_number = matches[4]
        metadata['Source'] = codes[code]
        metadata['Source Code'] = code_number
        metadata['Packet'] = packet
        metadata
    end

    def build_work_appearances(poem)
        output = []
        return unless poem.at('publication')
        codes = {
            'AB'=> "Ancestors' Brocades. By Millicent Todd Bingham. New York=> Harper, 1945.",
            'BM'=> "Bolts of Melody. Edited by Mabel Loomis Todd and Millicent Todd Bingham. New York=> Harper, 1945.",
            'CP'=> "The Complete Poems of Emily Dickinson. Edited by Martha Dickinson Bianchi and Alfred Leete Hampson. Boston=> Little, Brown, 1924.",
            'Centenary edition'=> "The Complete Poems of Emily Dickinson. Edited by Martha Dickinson Bianchi and Alfred Leete Hampson. Boston=> Little, Brown, 1930.",
            'FF'=> "Emily Dickinson Face to Face=> Unpublished Letters with Notes and Reminiscences. By Martha Dickinson Bianchi. Boston=> Houghton Mifflin, 1932.",
            'FP'=> "Further Poems of Emily Dickinson. Edited by Martha Dickinson Bianchi and Alfred Leete Hampson. Boston=> Litte, Brown, 1929.",
            'LH'=> "Emily Dickinson's Letters to Dr. and Mrs. Josiah Gilbert Holland. Edited by Theodora Van Wagenen Ward. Cambridge=> Harvard, 1951.",
            'LL'=> "The Life and Letters of Emily Dickinson. By Martha Dickinson Bianchi. Boston=> Houghton Mifflin, 1924.",
            'Letters'=> '',
            'Poems'=> '',
            'SH'=> "The Single Hound. Edited by Martha Dickinson Bianchi. Boston=> Little, Brown. 1914.",
            'UP'=> "Unpublished Poems of Emily Dickinson. Edited by Martha Dickinson Bianchi and Alfred Leete Hampson. Boston=> Little, Brown, 1935."
        }
        poems_editions = {
            1890 => "Poems of Emily Dickinson. Edited by Mabel Loomis Todd and T.W. Higginson. Boston: Roberts Brothers, 1890.",
            1891 => "Poems by Emily Dickinson, Second Series. Edited by T.W. Higginson and Mabel Loomis Todd. Boston: Roberts Brothers, 1891.",
            1896 => "Poems by Emily Dickinson, Third Series. Edited by Mabel Loomis Todd. Boston: Roberts Brothers, 1896.",
            'current' => "Poems by Emily Dickinson. Edited by Martha Dickinson Bianchi and Alfred Leete Hampson. Boston: Little, Brown, 1937."
        }
        letters_editions = {
            1894 => "Letters of Emily Dickinson. Edited by Mabel Loomis Todd. 2 vols. Boston: Roberts Brothers, 1894.",
            1931 => "Letters of Emily Dickinson. New and enlarged edition. Edited by Mabel Loomis Todd. New York: Harper, 1931."
        }
        pattern = Regexp.new("(#{codes.keys.join('|')}) \\((\\d{4}|current)\\), ([-0-9]*)(\\.|,)")
        matches = poem.at('publication').content.match(pattern)
        return if matches.nil?
        code = matches[1]
        year = matches[2]
        pages = matches[3]
        return unless code && year && pages
        publication = codes[code]
        publication = letters_editions[year] if code == 'Letters'
        publication = poems_editions[year] if code == 'Poems'
        output << WorkAppearance.new(
            :publication => publication,
            :year => year.to_i,
            :pages => pages
        )
        output
    end

    def locate_revisions!(edition)
        edition.works.each do |work|
            work.revisions.each do |e|
                next if e.start_address == 0
                line = work.line(e.start_line_number)
                if line && line.text.index(e.original_characters)
                    e.start_address = line.text.index(e.original_characters)
                    e.end_address = e.start_address if e.start_address
                    e.save!
                end
            end
        end
    end
end
