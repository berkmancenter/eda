require_relative 'char_map.rb'
module FieldParsing
    def get_division(text)
        division_pattern = /^(?<line_num>\d*) (?<division>.*)$/
        break_pattern = / <F38376(MI|M)?>(i|u)<F(255|58586)(D)?>/
        type_map = { 'i' => 'page_or_column', 'u' => 'line'}
        matches = text.match(division_pattern)
        divs = []
        if matches && matches['line_num'] && matches['division']
            # Create an emedation if this is a division with an implicit emendation
            emendation = matches['division'].split('] ')
            if emendation.count > 1
                chars = emendation[1]
                e = Emendation.new(
                    :start_line_number => matches['line_num'].to_i,
                    :end_line_number => matches['line_num'].to_i,
                    :original_characters => chars.gsub(break_pattern, ''),
                    :new_characters => emendation[0]
                )
            else
                chars = matches['division']
            end
            # We can have multiple new breaks per line, so build an array of
            # all the last characters in a line and their following line break
            all_lines = chars.split(break_pattern)
            all_lines.delete_if{|l| ['MI', 'M', '255', '58586', 'D'].include? l}
            all_lines.delete_at(all_lines.length - 1) unless ['i', 'u'].include?(all_lines.last)
            if all_lines.count % 2 != 0
                puts e.inspect
                puts "ALL Lines: #{all_lines}"
                exit
            end
            all_lines.each_slice(2) { |line_end| 
                divs << Division.new(
                    :start_line_number => matches['line_num'].to_i,
                    :end_line_number => matches['line_num'].to_i,
                    :original_characters => CharMap::replace(line_end[0]),
                    :subtype => type_map[line_end[1]]
                )
            }
            if e
                e.children = divs.dup
                divs << e
            end
            return divs
        else
            puts "mod: " + text
        end
    end

    def get_emendation(text)
        emendation_pattern = /(?<line_num>\d*) (?<alternates>.*)/
            matches = text.match(emendation_pattern)
        if matches && matches['line_num'] && matches['alternates']
            alts = matches['alternates'].split('] ')
            e = Emendation.new(
                :start_line_number => matches['line_num'].to_i,
                :end_line_number => matches['line_num'].to_i,
                :original_characters => CharMap::replace(alts[1]),
                :new_characters => CharMap::replace(alts[0])
            )
            e
        else
            puts "mod: " + text
        end
    end

    def get_alternate(text)
        alternate_pattern = /(?<line_num>\d*) (?<alternates>.*)/
            matches = text.match(alternate_pattern)
        if matches && matches['line_num'] && matches['alternates']
            alts = matches['alternates'].split('] ')
            if alts[0] && alts[1]
                a = Alternate.new(
                    :start_line_number => matches['line_num'].to_i,
                    :end_line_number => matches['line_num'].to_i,
                    :original_characters => CharMap::replace(alts[0]),
                    :new_characters => CharMap::replace(alts[1]),
                    :subtype => 'alternate'
                )
                a
            else
                puts "mod: " + text
            end
        end
    end

    def get_revision(text)
        revision_pattern = /(?<line_num>\d*) (?<revisions>.*)/
            matches = text.match(revision_pattern)
        if matches && matches['line_num'] && matches['revisions']
            alts = matches['revisions'].split('] ')
            if alts[0] && alts[1]
                r = Revision.new(
                    :start_line_number => matches['line_num'].to_i,
                    :end_line_number => matches['line_num'].to_i,
                    :original_characters => CharMap::replace(alts[0]),
                    :new_characters => CharMap::replace(alts[1])
                )
                r.start_line_number = matches['line_num'].to_i
                r
            else
                puts "mod: " + text
            end
        end
    end

    def parse_fascicle(text)
        text.gsub('<F53621>f<F255>','').split('.')
    end
end
