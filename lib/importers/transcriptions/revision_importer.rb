class RevisionImporter
    def get_work_from_xml(revision_xml)
        match = revision_xml['xml:id'].match(/(?<prefix>[A-Z]{1,2})(?<number>[0-9]{1,4})(?<variant>[A-Z](\.\d)?)/)
        work = Edition.find_by_work_number_prefix('F').works.find_by_number_and_variant(match[:number], match[:variant])
        return work
    end

    def import(filename)
        puts 'Importing revisions'
        @tei_importer = TEIImporter.new
        string = File.read(filename)
        doc = Nokogiri::XML(string)
        doc.css('div[type=franklin]').each do |revision|
            work = get_work_from_xml(revision)
            (revision > 'lg[type=altstanza]').each do |new_stanza|
                replace_stanza(work, new_stanza)
            end
            (revision > 'l').each do |line|
                new_line, modifiers = @tei_importer.parse_line(line).values
                old_line = work.line(new_line.number)
                puts %Q|Replacing "#{old_line.text}" with "#{new_line.text}"|
                stanza = old_line.stanza
                old_line.destroy
                stanza.lines << new_line
                work.line_modifiers << modifiers
            end
            add_notes(work, revision)
            work.save!
        end
    end

    def replace_stanza(work, stanza_xml)
        old_stanza = stanza_to_replace(work, stanza_xml)
        if old_stanza.nil?
            position = work.stanzas.count
        else
            position = old_stanza.position
        end
        new_stanza = Stanza.new(position: position)
        work.stanzas << new_stanza
        stanza_xml.css('l').each do |line|
            new_line, modifiers = @tei_importer.parse_line(line).values
            new_stanza.lines << new_line
            work.line_modifiers << modifiers
        end
        if old_stanza
            puts %Q|Replacing stanza with first line "#{old_stanza.lines.first.text}" with stanza with first line "#{new_stanza.lines.first.text}"|
            old_stanza.destroy
        else
            puts %Q|Adding new stanza with first line "#{new_stanza.lines.first.text}"|
        end
        work
    end

    def stanza_to_replace(work, stanza_xml)
        first_line = stanza_xml.at('l')['n'].to_i
        if old_line = work.line(first_line)
            return old_line.stanza
        else
            return nil
        end
    end

    def add_notes(work, work_xml)
        work_xml.css('note').each do |note|
            work.note = note.text.strip
        end
        work
    end
end
