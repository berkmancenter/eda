require 'csv'
class LexiconImporter
    def import(filename)
        CSV.foreach(filename) do |row|
            w = Word.find_or_create_by_word(row[0])
            w.attributes = ({:endings => row[1], :part_of_speech => row[2]})
            w.definitions << Definition.new(:number => row[3], :definition => row[4].strip)
            w.save!
        end
    end
end
