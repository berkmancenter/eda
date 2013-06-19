class JohnsonImporter
    def import(filename)
        edition = Edition.new(
            :name => 'The Poems of Emily Dickinson',
            :author => 'Thomas H. Johnson',
            :date => Date.new(1951, 1, 1),
            :work_number_prefix => 'J',
            :completeness => 0.95
        )
        edition.create_root_image_group(
            :name => "Images for #{edition.name}",
            :editable => false,
        )
        edition.root_image_group.edition = edition
        edition.root_image_group.save!

        text = File.readlines(filename)
        text.delete_if { |line| line.match /^\s*\[\s*\d*\s*\]\s*$/ }
        in_manuscript_block = false
        number_pattern = /^\s*\d+\s*$/ 
            text.map! do |line|
            output = nil
            if line.match(/Manuscript/) ||
                line.match(/^\s*(Manuscripts?|Publication):/) ||
                line.match(/^ {5}\w/) ||
                line.match(/^\s*\d+((-|, )\d+)?(\.|\])/) ||
                line.match(/No autograph/) ||
                line.match(/This.*poem/) ||
                line.match(/These lines/) ||
                line.match(/4 \[If/) ||
                (
                    line.length >= 70 && 
                    line.index('[no stanza').nil? &&
                    line.index('version of 18').nil?
                )
                in_manuscript_block = true
            end

            unless in_manuscript_block
                output = line.rstrip + "\n"
            end

            if line.match(number_pattern) && in_manuscript_block
                in_manuscript_block = false
            end

            if line.match(number_pattern)
                output = "</text></poem>\n<poem><number>#{line.strip}</number><text>"
            end
            output
            end
        poems = text.compact!.join.gsub("\n\n\n", "\n\n").gsub(/\n*\s*\[no stanza break\]\s*\n*/, "\n").gsub(/\n<\/text>/, '</text>').lines.to_a
        poems << poems[0]
        poems[0] = '<poems>'
        poems << '</poems>'
        #File.write(Rails.root.join('tmp', 'johnson.xml'), poems.join(''))
        doc = Nokogiri::XML::Document.parse(poems.join(''), nil, nil, Nokogiri::XML::ParseOptions::RECOVER)
        doc.css('poem').each do |poem|
            content = poem.css('text').map{|n| n.content}.join('').strip
            work = Work.new(:number => poem.css('number').text, :title => content.lines.first)
            stanza = Stanza.new(:position => 0)
            stanza_count = 0
            content.lines.each_with_index do |line, i|
                if line == "\n"
                    work.stanzas << stanza
                    stanza_count += 1
                    stanza = Stanza.new(:position => stanza_count)
                else
                    stanza.lines << Line.new(:text => line.strip, :number => i + 1)
                end
            end
            work.stanzas << stanza
            work.save!
            edition.works << work
        end
        edition.save!
    end
end
