class RevisionImporter
    def get_work_from_xml(revision_xml)
        match = revision_xml[:id].match(/(?<prefix>[A-Z]{1,2})(?<number>[0-9]{1,4})(?<variant>[A-Z])/)
        if match
            work = Edition.find_by_work_number_prefix('F').works.find_by_number_and_variant(match[:number], match[:variant])
            return work
        else
            puts revision_xml
            exit
        end
    end

    def import(filename)
        tei_importer = TEIImporter.new
        string = File.read(filename)
        doc = Nokogiri::XML(string)
        doc.css('div[type=franklin]').each do |revision|
            work = get_work_from_xml(revision)
            revision.css('l').each do |line|
                new_line, modifiers = tei_importer.parse_line(line).values
                old_line = work.line(new_line.number)
                stanza = old_line.stanza
                old_line.destroy
                stanza.lines << new_line
                work.line_modifiers << modifiers
            end
            add_notes(work, revision)
        end
    end
        
    def add_notes(work, work_xml)
        work_xml.css('note').each do |note|
            work.note = note.text.strip
        end
        work
    end
end
