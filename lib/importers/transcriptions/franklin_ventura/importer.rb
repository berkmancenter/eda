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

module FranklinVentura
    class Importer
        def create_edition
            edition = Edition.new(
                :name => 'The Poems of Emily Dickinson: Variorum Edition',
                :author => 'R. W. Franklin',
                :date => Date.new(1998, 1, 1),
                :work_number_prefix => 'F',
                :completeness => 1.0
            )
            edition.create_root_image_group(
                :name => "Images for #{edition.name}",
                :editable => false
            )
            edition.root_image_group.edition = edition
            edition.root_image_group.save!
            edition
        end

        def process_file(file)
            in_poem, ignore_next_line = false, false
            poem, stanza = nil, nil
            tags, variant_titles = [], []
            held_holder_code, held_holder_subcode, held_holder_id = nil, nil, nil
            file.each_line do |line|
                # Find tags that we'll have to translate
                #line.scan(/<([-0-9A-Z%]*)>/) { |m| tags << m[0] }
                if ignore_next_line
                    ignore_next_line = false
                    next
                end
                if line.match(Ignore_next_line_pattern)
                    ignore_next_line = true
                end

                # Is this a title?
                if line.match(Title_pattern)
                    match = Title_extractor.match(line)
                    if match && Title_extractor.named_captures.keys.all?{ |name| match[name] }
                        close_poem(poem) if poem
                        poem = Work.new(
                            :number => match[:number].to_i,
                            :title => CharMap::replace_no_itals(match[:title]).strip,
                            :date => Date.new(File.basename(file.path).to_i)
                        )
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

                # Add all our line modifieres
                add_modifiers!(poem, line)

                if line.match(Publication_pattern)
                    publications = line.match(Publication_extractor)['publications']
                    publications.scan(Published_extractor) do |match|
                        args = Hash[Published_extractor.names.zip(match)]
                        begin
                            date = Date.parse([args['year'], args['month'], args['day']].join('-').gsub(/-*$/, ''))
                        rescue
                            date = nil
                        end
                        poem.appearances << WorkAppearance.new(:year => args['year'].to_i, :date => date)
                    end
                end

                if in_poem
                    # Setup the stanza
                    stanza = Stanza.new if line.match(Stanza_start_pattern)

                    if line.match(Stanza_boundary_pattern)
                        poem.stanzas << stanza
                        stanza = Stanza.new
                    end

                    matches = Poem_line_extractors.map{ |e| e.match(line) } \
                        .delete_if{|m| m.nil?} \
                        .reduce({}){|captures, match| captures.merge(match.named_captures)}

                    unless matches.empty?
                        # If we have a new variant, create a new poem
                        if matches['variant']
                            if poem.variant.nil?
                                poem.variant = CharMap::replace_no_itals(matches['variant'])
                                puts "poem: #{poem.number} #{poem.variant}"
                            else
                                title = variant_titles.empty? ? poem.title : variant_titles.shift
                                close_poem(poem)
                                poem = Work.new(
                                    :number => poem.number,
                                    :title => CharMap::replace_no_itals(title).strip,
                                    :variant => CharMap::replace(matches['variant']),
                                    :date => Date.new(File.basename(file.path).to_i)
                                )
                                puts "poem: #{poem.number} #{poem.variant}"
                            end
                        end

                        stanza_line = Line.new(:text => CharMap::replace(matches['line']))
                        stanza_line.number = line_number(poem, stanza, matches)
                        stanza.lines << stanza_line
                    end

                    # Add stanza to poem if complete
                    if line.match(Poem_end_pattern)
                        poem.stanzas << stanza
                        in_poem = false
                    end
                end
            end
            close_poem(poem) if poem
        end

        def import(directory, from_year = 1850, to_year = 1886, error_check = true)
            edition = create_edition
            @poems = []

            Dir.open(directory).sort.each do |filename|
                next unless File.extname(filename) == '.TXT' && (from_year..to_year).include?(filename.to_i)
                process_file(File.open("#{directory}/#{filename}"))
            end

            edition.works = @poems
            edition.save!
            post_process!(edition, error_check)
        end

        def add_modifiers!(poem, line)
            ['division', 'emendation', 'revision', 'alternate'].each do |var|
                capped = var.camelize
                next unless line.match("Patterns::#{capped}_pattern".constantize)
                instances = prep_modifier(line, "Patterns::#{capped}_extractor".constantize, var.pluralize)
                instances.each do |instance|
                    i = self.send("get_#{var}", instance)
                    poem.line_modifiers.push(*i) if i 
                end
            end
        end

        def close_poem(poem)
            assign_stanza_positions(poem)
            poem.save!
            @poems << poem
        end

        def line_number(poem, stanza, matches)
            line_num = nil
            # Get line number
            if stanza.lines.empty? && (poem.stanzas.empty? || poem.stanzas.count == 1)
                line_num = 1
            elsif stanza.lines.last && stanza.lines.last.number
                line_num = stanza.lines.last.number + 1
            elsif poem.stanzas.last.lines.last && poem.stanzas.last.lines.last.number
                line_num = poem.stanzas.last.lines.last.number + 1
            end
            if matches['line_num'].to_i > 0
                line_num = matches['line_num'].to_i
            end
            line_num
        end

        def post_process!(edition, error_check = false)
            locate_emendations!(edition)
            locate_divisions!(edition)
            locate_alternates!(edition)
            fix_exceptions!(edition)
            group_variants(edition)
            check_for_errors(edition) if error_check
        end

        def fix_exceptions!(edition)
            w = Work.find_by_number_and_variant(325, 'C')
            w.stanzas.each_with_index{|s| s.destroy if s.position > 6} if w
            w = Work.find_by_number_and_variant(321, 'C')
            w.stanzas.each_with_index{|s| s.destroy if s.position > 0} if w
        end

        def group_variants(edition)
            group = []
            edition.works.each do |work|
                if group.empty? || group.last.number == work.number
                    group << work
                elsif group.count > 1 && group.last.number != work.number
                    wg = WorkGroup.new(:name => "#{group.last.number} variants")
                    group.each{ |w| wg.works << w }
                    wg.save!
                    group = [work]
                else
                    group = [work]
                end
            end
        end

        def check_for_errors(edition)
            find_errors(edition.works.all)
        end

        def prep_modifier(modifier, extractor, extracted)
            mods = modifier.match(extractor)[extracted].split('<_><|><~>').drop(1) \
                .map{|d| d.gsub("\r\n ",'').strip.split('<R>') }.flatten \
                .delete_if do |d|
                if d.include?('<MI>') 
                    puts "mod: #{d}"
                    true
                else
                    false 
                end
                end
        end

        def assign_stanza_positions(poem)
            poem.stanzas.each_with_index do |s, i|
                s.position = i
            end
        end

        def pattern(chars)
            Regexp.new("(^|\\b|\\s)#{Regexp.escape(chars)}($|\\b|\\s)")
        end

        def locate_emendations!(edition)
            edition.works.each do |work|
                work.emendations.each do |e|
                    next unless e.start_address == nil && e.new_characters
                    pattern = pattern(e.new_characters)
                    line = work.line(e.start_line_number)
                    mods = line.line_modifiers if line
                    if mods && mods.count > 1
                        mods.sort_by!{|mod| line.text.index(pattern(mod.original_characters)) || 0 }.reverse!
                        mods.each do |mod|
                            pull_emendation(line, mod)
                        end
                    else
                        pull_emendation(line, e)
                    end
                end
            end
        end

        def pull_emendation(line, e)
            return unless line && e.new_characters && match = line.text.match(pattern(e.new_characters))
            e.start_address = match.offset(0)[0]
            e.start_address += 1 if match[0][0] == ' '
            e.end_address = e.start_address + e.new_characters.length if e.start_address
            e.save!
            line.text = line.text.sub(e.new_characters, '')
            line.save!
        end

        def locate_divisions!(edition)
            edition.works.each do |work|
                work.divisions.each do |e|
                    if e.parent
                        line = e.parent.chars.join
                    elsif work.line(e.start_line_number)
                        line = work.line(e.start_line_number).text
                    end
                    if line && line.index(e.original_characters)
                        e.start_address = line.index(e.original_characters) + e.original_characters.length
                        e.end_address = e.start_address if e.start_address
                        e.save!
                    end
                end
            end
        end

        def locate_alternates!(edition)
            edition.works.each do |work|
                work.alternates.each do |e|
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
end
