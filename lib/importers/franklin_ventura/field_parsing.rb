require_relative 'char_map.rb'
module FieldParsing
    def get_division(text)
        division_pattern = /(?<line_num>\d*) (?<last_chars>.*) <F38376>(?<type>(i|u))<F(255|58586)>/
            type_map = { 'i' => 'page_or_column', 'u' => 'line'}
        matches = text.match(division_pattern)
        if matches && matches['line_num'] && matches['last_chars'] && matches['type']
            d = Division.new(
                :start_line_number => matches['line_num'].to_i,
                :end_line_number => matches['line_num'].to_i,
                :original_characters => CharMap::replace(matches['last_chars']),
                :subtype => type_map[matches['type']]
            )
            d
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
