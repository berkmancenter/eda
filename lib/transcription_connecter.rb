require 'csv'
class TranscriptionConnecter
    COLUMN_NAME_TO_PREFIX_MAP = {
        :johnson => 'J',
        :franklin => 'F'
    }

    def update_map
        top_scores = []
        CSV.foreach(Rails.root.join('tmp', 'gutenberg_similarities.csv'), headers: true, converters: :numeric) do |row|
            g_work = Work.find(row[0])
            scores = row.values_at(1..-1)
            top_score = scores.sort.last
            f_work = Work.find(row.headers[scores.index(top_score) + 1])
            top_scores << [g_work.id, f_work.id, top_score]
            puts "#{g_work.lines.first.text}\n#{f_work.lines.first.text}\n#{top_score}\n\n"
        end
        puts top_scores.inspect
    end

    def match_by_text
        output_file = CSV.open(Rails.root.join('tmp', 'gutenberg_similarities.csv'), 'wb')
        gutenberg = Edition.find_by_work_number_prefix('G')
        franklin = Edition.find_by_work_number_prefix('F')
        franklin_texts = {}
        output = {}
        franklin.works.each do |work|
            puts work.number
            franklin_texts[work.id] = work.text
        end

        gutenberg.works.each do |g_work|
            puts g_work.id
            output[g_work.id] = {}
            franklin_texts.each do |f_id, f_text|
                score = g_work.text.downcase.jarowinkler_similar(f_text.downcase)
                #g.metadata['Similar Franklin Works'] << "#{f_id}: #{score}"
                output[g_work.id][f_id] = score
            end
        end

        output_file << [''] + franklin_texts.keys.sort
        output.each do |g_id, fs|
            output_file << [g_id] + fs.values
        end
    end

    def connect(work_map, publication_history_file)
        match_by_text
        exit
        Work.all.each do |work|
            parse_publication_field(work)
        end
        exit
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

    def parse_publication_field(work)
        johnson_pattern = /<em>Poems<\/em> \(1955\).*<em>(\[?[A-Z]\.?[0-9]?\]?<\/em> principal)/
        work.metadata['Publications'].each do |pub|
            next unless match = pub.match(johnson_pattern)
            puts match.inspect
        end
    end
end
