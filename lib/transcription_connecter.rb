require 'csv'
class TranscriptionConnecter
    COLUMN_NAME_TO_PREFIX_MAP = {
        :johnson => 'J',
        :franklin => 'F'
    }
    def connect(work_map, publication_history_file)
        map = CSV.read(work_map, {:headers => true, :converters => :integer}).to_a[1..-1]
        franklin = Edition.find_by_work_number_prefix('F')
        CSV.foreach(publication_history_file, headers: true) do |row|
            next unless row['Publication'] == 'Poems' && row['Year'] == '1955' && row['Source Variant'] && row['Source Variant'].match(/[A-Z]*/)
            if row['Source Variant'].length > 1 && row['Notes'] && match = row['Notes'].match(/\[?(?<variant>[A-Z](\.[0-9])?)\]? principal/)
                variant = match[:variant]
            elsif match = row['Source Variant'].match(/^[A-Z]$/)
                variant = match.to_s
            else
                next
            end
            franklin_number = row['Franklin Number'].to_i
            row = map.find{|row| row[1].to_i == franklin_number}
            if row
                johnson_number = row[0]
            else
                johnson_number = "WHAT: #{franklin_number}"
            end
            puts "#{johnson_number} #{franklin_number} #{variant}"
            #works = get_works(row)
            #works.each do |work|
            #    work.note = row['Notes']
            #    work.save!
            #end
        end
    end
end
