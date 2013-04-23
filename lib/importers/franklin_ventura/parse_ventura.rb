# This has a lot to do:
# Create Franklin edition
# Create the works, lines, stanzas, and line modifiers
# Set numbers?
# Variant collections

require_relative 'error_checking.rb'
require_relative 'field_parsing.rb'
require_relative 'char_map.rb'
require_relative 'patterns.rb'

include ErrorChecking
include FieldParsing
include Patterns

class MatchData
    def named_captures
        Hash[ self.names.zip( self.captures ) ]
    end
end

class FranklinVenturaImporter
    def import(directory, from_year = 1850, to_year = 1886)
        edition = Edition.new(
            :name => 'The Poem of Emily Dickinson: Variorum Edition',
            :author => 'R. W. Franklin',
            :date => Date.new(1998, 1, 1),
            :work_number_prefix => 'F',
            :completeness => 1.0
        )
        poems = []
        in_poem = false
        poem, stanza, line = nil, nil, ''

        tags = []
        variant_titles = []

        multiline_title = false
        in_division, in_emendation, in_alternate, in_revision, in_publication = false, false, false, false, false
        division, emendation, alternate, revision, publication = '', '', '', '', ''
        held_holder_code, held_holder_subcode, held_holder_id = nil, nil, nil

        Dir.open(directory).sort.each do |filename|
            next unless File.extname(filename) == '.TXT' && (from_year..to_year).include?(filename.to_i)
            File.open("#{directory}/#{filename}").each_line do |line|

                # Find tags that we'll have to translate
                line.scan(/<([-0-9A-Z%]*)>/) { |m| tags << m[0] }

                # Continue adding to the title
                if multiline_title
                    poem.title = poem.title[0..-5] + ' ' + line.strip!
                    multiline_title = false
                    next
                end

                # Is this a title?
                if line.match(Title_pattern)
                    match = Title_extractor.match(line)
                    if match && Title_extractor.named_captures.keys.all?{ |name| match[name] }
                        multiline_title = !!match[:title].index('<R>')
                        if poem
                            poem.save! 
                            poems << poem
                        end
                        poem = Work.new(:number => match[:number].to_i, :title => CharMap::replace_no_itals(match[:title]), :date => Date.new(filename.to_i))
                    end
                end

                if held_holder_code && in_poem
                    poem.holder_code = held_holder_code
                    held_holder_code = nil
                end
                if held_holder_subcode && in_poem
                    poem.holder_subcode = held_holder_subcode
                    held_holder_subcode = nil
                end
                if held_holder_id && in_poem
                    poem.holder_id = held_holder_id
                    held_holder_id = nil
                end

                if holder_match = line.match(Holder_extractor)
                    held_holder_code = holder_match[:loc_code].upcase.strip if holder_match[:loc_code]
                    held_holder_subcode = holder_match[:subloc_code].upcase.strip if holder_match[:subloc_code]
                    if holder_match[:subloc_code] == 'PC'
                        held_holder_subcode = '1896PC'
                    end
                    held_holder_id = holder_match[:id].strip if holder_match[:id]

                end

                # Is this a second or third title?
                match = Variant_title_extractor.match(line)
                variant_titles << match[:title] if match && match[:title]

                in_poem = true if line.match(Poem_start_pattern)

                in_division = true if line.match(Division_pattern)
                in_emendation = true if line.match(Emendation_pattern)
                in_publication = true if line.match(Publication_pattern)
                in_revision = true if line.match(Revision_pattern) && in_poem
                in_alternate = true if line.match(Alternate_pattern) && in_poem && !in_revision

                def prep_modifier(modifier, extractor, extracted)
                    modifier.match(extractor)[extracted].lines.to_a.join(' ') \
                        .split('<_><|><~>').drop(1).map{|d| d.gsub("\r\n ",'').strip.split('<R>') }.flatten
                end

                if in_division
                    if line[0] == '@' && line.match(Division_pattern).nil?
                        divisions = prep_modifier(division, Division_extractor, 'divisions')
                        divisions.each do |div|
                            d = get_division(div)
                            poem.divisions << d if d 
                        end
                        in_division = false
                        division = ''
                    else
                        division << line
                    end
                end

                if in_emendation
                    if line[0] == '@' && line.match(Emendation_pattern).nil?
                        emendations = prep_modifier(emendation, Emendation_extractor, 'emendations')
                        emendations.each do |emend|
                            e = get_emendation(emend)
                            poem.emendations << e if e
                        end
                        in_emendation = false
                        emendation = ''
                    else
                        emendation << line
                    end
                end

                if in_revision
                    if line[0] == '@' && line.match(Revision_pattern).nil?
                        revisions = prep_modifier(revision, Revision_extractor, 'revisions')
                        revisions.each do |emend|
                            e = get_revision(emend)
                            poem.revisions << e if e
                        end
                        in_revision = false
                        revision = ''
                    else
                        revision << line
                    end
                end

                if in_alternate
                    if line[0] == '@' && line.match(Alternate_pattern).nil?
                        alternates = prep_modifier(alternate, Alternate_extractor, 'alternates')
                        alternates.each do |vari|
                            v = get_alternate(vari)
                            poem.alternates << v if v
                        end
                        in_alternate = false
                        alternate = ''
                    else
                        alternate << line
                    end
                end

                if in_publication
                    if line[0] == '@' && line.match(Publication_pattern).nil?
                        publications = publication.match(Publication_extractor)['publications'].lines.to_a.join(' ').gsub("\r\n ",'').strip
                        publications.scan(Published_extractor) do |match|
                            args = Hash[Published_extractor.names.zip(match)]
                            begin
                            date = Date.parse([args['year'], args['month'], args['day']].join('-').gsub(/-*$/, ''))
                            rescue
                                date = nil
                            end
                            poem.appearances << WorkAppearance.new(:year => args['year'].to_i, :date => date)
                        end
                        in_publication = false
                        publication = ''
                    else
                        publication << line
                    end
                end

                if in_poem
                    # Setup the stanza
                    if line.match(Stanza_start_pattern)
                        stanza = Stanza.new
                    end
                    if line.match(Stanza_boundary_pattern)
                        poem.stanzas << stanza
                        stanza = Stanza.new
                    end

                    # Add line to stanza
                    matches = Poem_line_extractors.map{ |e| e.match(line) }.delete_if{|m| m.nil?}.reduce({}) {|captures, match| captures.merge(match.named_captures)}
                    unless matches.empty?
                        if stanza.lines.empty? && poem.stanzas.empty?
                            line_num = 1
                        elsif stanza.lines.last && stanza.lines.last.number
                            line_num = stanza.lines.last.number + 1
                        elsif poem.stanzas.last.lines.last.number
                            line_num = poem.stanzas.last.lines.last.number + 1
                        end
                        if matches['line_num'].to_i > 0
                            line_num = matches['line_num'].to_i
                        end
                        stanza_line = Line.new(:text => CharMap::replace(matches['line']))
                        stanza_line.number = line_num if line_num
                        stanza.lines << stanza_line

                        # If we have a new variant, create a new poem
                        if matches['variant']
                            if poem.variant.nil?
                                poem.variant = matches['variant']
                            else
                                title = variant_titles.empty? ? poem.title : variant_titles.shift
                                poem.save!
                                poems << poem
                                poem = Work.new(
                                    :number => poem.number,
                                    :title => CharMap::replace_no_itals(title),
                                    :variant => CharMap::replace(matches['variant']),
                                    :date => Date.new(filename.to_i)
                                )
                            end
                        end
                    end

                    # Add stanza to poem if complete
                    if line.match(Poem_end_pattern)
                        poem.stanzas << stanza
                        in_poem = false
                    end
                end
            end
        end
        if poem
            poem.save
            poems << poem
        end
        poems
        edition.works = poems
        edition.save!
        post_process!
    end

    def group_variants
        Edition.find_by_author('R. W. Franklin')
    end

    def post_process!
        works = Edition.find_by_author('R. W. Franklin').works
        works.each do |work|
            work.emendations.each do |e|
                line = work.line(e.start_line_number)
                e.start_address = line.text.index(e.original_characters) if line
                e.end_address = e.start_address + e.original_characters.length if e.start_address
                e.save!
            end
        end
    end
end
