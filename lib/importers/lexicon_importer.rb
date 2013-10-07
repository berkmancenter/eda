require 'csv'
class LexiconImporter
    def import(term_file, definition_file)
        puts 'Importing BYU Lexicon'
        defs = CSV.read(definition_file)
        pbar = ProgressBar.new("Lexicon", CSV.readlines(term_file).count)
        CSV.foreach(term_file) do |row|
            w = Word.find_or_create_by_word(row[1].strip)
            w.sortable_word = row[2].strip
            variant = w.variants.new(
                :endings => row[3],
                :part_of_speech => row[4],
            )
            variant.etymology = unescape(row[6].strip) if row[6]
            word_defs = defs.select{|d| d[1] == row[0]}
            word_defs.each do |word_def|
                puts word_def.inspect unless word_def[2]
                variant.definitions << Definition.new(
                    :number => word_def[3],
                    :definition => unescape(word_def[2].strip)
                )
            end
            w.save!
            pbar.inc
        end
    end

    def unescape(string)
        return string.gsub('<', '&lt;')
                .gsub('>', '&gt;')
                .gsub('__i__', '<em>')
                .gsub('__/i__', '</em>')
                .gsub('__b__', '<strong>')
                .gsub('__/b__', '</strong>')
    end
end
