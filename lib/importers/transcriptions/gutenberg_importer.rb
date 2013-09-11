#!/bin/env ruby
# encoding: utf-8

class GutenbergImporter

    def import(filename)
        editions = create_editions
        text = File.open(filename, 'r:ISO-8859-1:UTF-8').read
        xml = turn_into_xml(text)
        File.write(Rails.root.join('tmp', 'gutenberg_test.xml'), xml)
        series = parse_xml(xml)
        editions.each_with_index do |edition, i|
            edition.works = series[i]
            edition.save!
        end
    end

    def create_editions
        first_edition = Edition.new(
            :name => 'Poems: First Series',
            :author => 'Emily Dickinson',
            :date => Date.new(1890, 1, 1),
            :work_number_prefix => 'P90-',
            :completeness => 0.8,
            :public => true
        )
        first_edition.create_image_set(
            name: "Images for #{first_edition.name}",
            editable: true
        )
        first_edition.create_work_set(
            name: "Works in #{first_edition.name}",
            editable: true
        )
        second_edition = Edition.new(
            :name => 'Poems: Second Series',
            :author => 'Emily Dickinson',
            :date => Date.new(1891, 1, 1),
            :work_number_prefix => 'P91-',
            :completeness => 0.8,
            :public => true
        )
        second_edition.create_image_set(
            name: "Images for #{second_edition.name}",
            editable: true
        )
        second_edition.create_work_set(
            name: "Works in #{second_edition.name}",
            editable: true
        )
        third_edition = Edition.new(
            :name => 'Poems: Third Series',
            :author => 'Emily Dickinson',
            :date => Date.new(1896, 1, 1),
            :work_number_prefix => 'P96-',
            :completeness => 0.8,
            :public => true
        )
        third_edition.create_image_set(
            name: "Images for #{third_edition.name}",
            editable: true
        )
        third_edition.create_work_set(
            name: "Works in #{third_edition.name}",
            editable: true
        )
        [first_edition, second_edition, third_edition]
    end
    
    
    def turn_into_xml(string)
        xml = ''
        start_pattern = /<a name=/
        end_pattern = /<hr /
        metadata_pattern = /^<br>\r\n(?<number>[IXVL]*)\.<br>\r\n(<br>\r\n(?<title>[ A-ZË']*)(\.|!)<br>)?/m
        string.gsub!(start_pattern, "<work>\n\\0")
        string.gsub!(end_pattern, "</work>\n\\0")
        string.gsub!(metadata_pattern, "<number>\\k<number></number>\n<title>\\k<title></title>")
        string.gsub!(/^([^<]+)<br>/, '\1')
        string.gsub!(/^<br>\r\n<br>\r\n/, "<br>\n")
        string.gsub!(/title>(\r\n)?<br>/, "title>")
        string.gsub!(/<br>[\r\n]+<(\/?)(work|series)>/, '<\1\2>')
        string.gsub!(/<br>[\r\n]+<number>/, '<number>')
        string.gsub!(/<\/title>/, "</title>\n<poem>\n<stanza>")
        string.gsub!('</work>', "</stanza>\n</poem>\n</work>")
        string.gsub!(/^[^<\n]+$/, '<line>\0</line>')
        string.gsub!(/^<br>/, "</stanza>\n<stanza>")

        string.gsub!('<br>', '<br/>')
        string.gsub!("\r", '')
        string.gsub!(/^(<hr[^>]*)>/, '\1/>')
        "<works>\n#{string}\n</works>"
    end

    def parse_xml(xml)
        seri = []
        doc = Nokogiri::XML::Document.parse(xml, nil, nil, Nokogiri::XML::ParseOptions::RECOVER)
        pbar = ProgressBar.new("Parse XML", doc.css('work').count)
        doc.css('series').each do |series|
            works = []
            series.css('work').each_with_index do |work, i|
                w = Work.new(
                    number: i + 1,
                    title: work.at('title').text.empty? ? work.at('line').text : work.at('title').text
                )
                w.metadata['Numeral'] = work.at('number').text if work.at('number')
                work.css('stanza').each_with_index do |stanza, i|
                    s = w.stanzas.build(position: i)
                    stanza.css('line').each do |line|
                        line_number = line_number(w, s)
                        s.lines.build(
                            text: line.inner_html,
                            number: line_number
                        )
                    end
                end
                works << w
                pbar.inc
            end
            seri << works
        end
        seri
    end

    def line_number(poem, stanza)
        line_num = nil
        # First line of work
        if stanza.lines.empty? && (poem.stanzas.empty? || poem.stanzas.size == 1)
            line_num = 1
            # Next line in current stanza 
        elsif stanza.lines.last && stanza.lines.last.number
            line_num = stanza.lines.last.number + 1
            # Next line in new stanza
        elsif stanza.position > 0 && poem.stanzas[-2].lines.last.number
            line_num = poem.stanzas[-2].lines.last.number + 1
        else
            puts poem.stanzas.inspect
            puts stanza.lines.inspect
            exit
        end
        line_num
    end
end
