class Array
    def subtract_once(b)
        h = b.inject({}) {|memo, v|
            memo[v] ||= 0; memo[v] += 1; memo
        }
        reject { |e| h.include?(e) && (h[e] -= 1) >= 0 }
    end
end

class TranscriptionErrorFinder
    def puts_empty(poem)
        puts "Poem #{poem.number}#{poem.variant if poem.variant} (#{poem.date.year}) has no lines" if poem.lines.empty?
    end

    def puts_sparse(poem)
        confirmed_sparse = [
            'F244[A]',
            'F277[A]',
            'F283[A]',
            'F314[A]',
            'F376[A]',
            'F442[A]',
            'F496[A]',
            'F501[A]',
            'F529[A]',
            'F534[A]',
            'F572[A]',
            'F577[A]',
            'F822[A]',
            'F852[A]',
            'F923[A]',
            'F935[A]',
            'F1166[A]',
            'F1286A',
            'F1296A',
            'F1349A'
        ]
        if poem.lines.count <= 3 && !confirmed_sparse.include?("#{poem.edition.work_number_prefix}#{poem.number}#{poem.variant}".gsub(/(<i>|<\/i>)/,''))
            puts "Poem #{poem.edition.work_number_prefix}#{poem.number}#{poem.variant if poem.variant} (#{poem.date.year if poem.date}) has few lines"
        end
    end

    def puts_mismatched_lines(poem)
        line_numbers = poem.lines.map{|l| l.number}
        good_number_range = (1..poem.lines.count).to_a 
        problem_lines = (line_numbers.subtract_once(good_number_range)) + (good_number_range.subtract_once(line_numbers)).sort!
        puts "Poem #{poem.number}#{poem.variant if poem.variant} (#{poem.date.year}): line numbers don't match (#{problem_lines})" unless problem_lines.empty?
    end

    def puts_missing_numbers(poems)
        poem_numbers = poems.map{|p| p.number}.uniq
        min, max = *poem_numbers.minmax
        total_set = (min..max).to_a
        missing = total_set - poem_numbers
        puts "Missing poem numbers: #{missing.join(', ')}" unless missing.empty?
    end

    def puts_maladdressed_mods(poem)
        poem.line_modifiers.each do |mod|
            puts "#{mod.type} #{mod.id} @ Poem: #{poem.number}#{poem.variant} Line: #{mod.start_line_number} - #{mod.start_address} : (#{mod.original_characters}) - (#{mod.new_characters}) - '#{poem.line(mod.start_line_number).text if poem.line(mod.start_line_number)}'" if mod.start_address == nil || mod.start_line_number == nil || mod.start_line_number == 0
        end
    end

    def puts_without_numbers(poems)
        poems.each do |poem|
            puts "Poem ID: #{poem.id} doesn't have a number" if poem.number.nil?
        end
    end

    def find_missing_variants(poems)
        # Make the first variant is A and that there aren't any missing between
        # A and last letter
        #  number | variant 
        # --------+---------
        #      49 | A.2
        #     181 | B
        #     311 | B
        #     569 | B
        #     755 | B
        #     890 | B
        #    1382 | B
        # 
    end

    def find_errors(poems)
        puts_missing_numbers(poems)
        puts_without_numbers(poems)
        poems.each do |poem|
            puts_empty(poem)
        end
        poems.each do |poem|
            puts_sparse(poem)
        end
        poems.each do |poem|
            puts_mismatched_lines(poem)
        end
        poems.each do |poem|
            puts_maladdressed_mods(poem)
        end
    end
end
