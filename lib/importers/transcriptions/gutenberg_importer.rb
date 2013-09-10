#!/bin/env ruby
# encoding: utf-8

class GutenbergImporter
    def import(filename)
        edition = Edition.new(
            :name => 'Poems: Three Series, Complete',
            :author => 'Emily Dickinson',
            :date => Date.new(2004, 5, 3),
            :work_number_prefix => 'G',
            :completeness => 0.8,
            :public => true
        )
        edition.create_image_set(
            name: "Images for #{edition.name}",
            editable: true
        )
        edition.create_work_set(
            name: "Works in #{edition.name}",
            editable: true
        )
        start_pattern = /<a name=/
        end_pattern = /<hr /
        metadata_pattern = /^<br>\r\n(?<number>[IXVL]*)\.<br>\r\n(<br>\r\n(?<title>[ A-ZË']*)(\.|!)<br>)?/m
        text = File.open(filename, 'r:ISO-8859-1:UTF-8')
        poem = []
        in_poem = false
        text.each do |line|
            if line.match end_pattern
                in_poem = false
                poem_body = poem.join('').gsub(/(\r\n<br>)*\r\n$/,'')
                matches = poem_body.match(metadata_pattern)
                poem_body = poem_body.gsub(matches[0], '').strip
                stanzas = poem_body.split(/\r\n<br>/)
                p = Work.new(:title => matches[:title], :number => edition.works.length + 1)
                line_num = 1
                stanzas.each_with_index do |stanza, i|
                    s = Stanza.new(:position => i)
                    stanza.split(/<br>\r\n/).each do |line|
                        text = line.gsub('<br>', '').strip
                        unless text.empty?
                            s.lines << Line.new(:text => text, :number => line_num)
                            line_num += 1
                        end
                    end
                    p.stanzas << s
                end
                edition.works << p
                poem = []
            end
            if in_poem
                poem << line
            end
            if line.match start_pattern
                in_poem = true
            end
        end
        edition.save!
    end
end
