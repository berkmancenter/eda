require_relative 'char_map.rb'
module FieldParsing
    def get_division(text)
        division_pattern = /^(?<line_num>\d*) (?<division>.*)$/
        break_pattern = / (\|\|?)/
        type_map = { '||' => 'page_or_column', '|' => 'line'}
        matches = text.match(division_pattern)
        divs = []
        if matches && matches['line_num'] && matches['division']
            # Create an emedation if this is a division with an implicit emendation
            emendation = matches['division'].split('] ')
            if emendation.count > 1
                chars = emendation[1]
                if chars.gsub(break_pattern, '').nil?
                    puts emendation.inspect
                    #exit
                end
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
            #all_lines.delete_if{|l| ['MI', 'M', '255', '58586', 'D'].include? l}
            all_lines.delete_at(all_lines.length - 1) unless all_lines.last.last == '|'
            if all_lines.count % 2 != 0
                puts "ALL Lines: #{all_lines}"
                exit
            end
            all_lines.each_slice(2) { |line_end| 
                divs << Division.new(
                    :start_line_number => matches['line_num'].to_i,
                    :end_line_number => matches['line_num'].to_i,
                    :original_characters => line_end[0].strip,
                    :subtype => type_map[line_end[1]]
                )
            }
            if e
                e.children = divs.dup
                divs << e
            end
            return divs
        else
            #puts "div mod: " + text
        end
    end

    def get_emendation(text)
        emendation_pattern = /(?<line_num>\d*) (?<alternates>.*)/
        matches = text.match(emendation_pattern)
        if matches && matches['line_num'] && matches['alternates']
            alts = matches['alternates'].split(']')
            return unless alts.size == 2
            e = Emendation.new(
                :start_line_number => matches['line_num'].to_i,
                :end_line_number => matches['line_num'].to_i,
                :original_characters => alts[1].strip,
                :new_characters => alts[0].strip
            )
            e
        else
            #puts "emend mod: " + text
        end
    end

    def get_alternate(text)
        a = []
        alternate_pattern = /(?<line_num>\d+) (?<alternates>.*)/
        full_line_alternate_pattern = /(?<line_num>\d+)\] (?<alternates>.*)/
        matches = text.match(alternate_pattern)
        full_line_matches = text.match(full_line_alternate_pattern)
        if matches && matches['line_num'] && matches['alternates']
            alts = matches['alternates'].split('] ')
            if alts[0] && alts[1]
                alts[1].split('&#8226;').each do |alt|
                    a << Alternate.new(
                        :start_line_number => matches['line_num'].to_i,
                        :end_line_number => matches['line_num'].to_i,
                        :original_characters => alts[0].strip,
                        :new_characters => alt.strip,
                        :subtype => 'alternate'
                    )
                end
                return a
            else
                #puts matches.inspect
                #puts alts.inspect
                #puts "alt mod: " + text
            end
        elsif full_line_matches && full_line_matches['line_num'] && full_line_matches['alternates']
                a = Alternate.new(
                    :start_line_number => full_line_matches['line_num'].to_i,
                    :end_line_number => full_line_matches['line_num'].to_i,
                    :start_address => 0,
                    :end_address => 9999,
                    :original_characters => '',
                    :new_characters => full_line_matches['alternates'].strip,
                    :subtype => 'alternate'
                )
                return a
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
                    :original_characters => alts[0].strip,
                    :new_characters => alts[1].strip
                )
                r.start_line_number = matches['line_num'].to_i
                r
            else
                #puts "revise mod: " + text
            end
        end
    end

    def parse_fascicle(text)
        text.gsub('<F53621>f<F255>','').split('.')
    end
end
