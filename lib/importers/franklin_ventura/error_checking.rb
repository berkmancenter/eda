class Array
    def subtract_once(b)
        h = b.inject({}) {|memo, v|
            memo[v] ||= 0; memo[v] += 1; memo
        }
        reject { |e| h.include?(e) && (h[e] -= 1) >= 0 }
    end
end

module ErrorChecking
    def puts_empty(poem)
        puts "Poem #{poem.number}#{poem.variant if poem.variant} (#{poem.date.year}) has no lines" if poem.lines.empty?
    end

    def puts_sparse(poem)
        confirmed_sparse = ['244[A]', '277[A]', '283[A]', '314[A]', '376[A]', '442[A]', '496[A]', '501[A]', '529[A]', '534[A]', '572[A]', '577[A]', '822[A]', '852[A]', '923[A]', '935[A]', '1166[A]', '1286A', '1296A', '1349A']
        if poem.lines.count == 1 && !confirmed_sparse.include?(CharMap::replace_no_itals(poem.number.to_s + poem.variant))
            puts "Poem #{poem.number}#{poem.variant if poem.variant} (#{poem.date.year}) has few lines"
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

    def find_errors(poems)
        puts_missing_numbers(poems)
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
