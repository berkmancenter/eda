require 'csv'
class TranscriptionConnecter
    COLUMN_NAME_TO_PREFIX_MAP = {
        :johnson => 'J',
        :franklin => 'F'
    }

    def update_map
        map_filename = Eda::Application.config.emily['data_directory'] + '/work_map.csv'
        score_threshold = 0.7714
        top_scores = []
        matched_johnson_numbers = []
        map = CSV.read(map_filename, headers: true)
        temp_map = CSV.open(map_filename + '.tmp', 'wb')
        temp_map << (map.headers + [:gutenberg])
        CSV.foreach(Eda::Application.config.emily['data_directory'] + '/gutenberg_similarities_pair_distance.csv', headers: true, converters: :numeric) do |row|
            g_work = Work.find(row[0])
            scores = row.values_at(1..-1)
            top_score = scores.sort.last
            f_work = Work.find(row.headers[scores.index(top_score) + 1])
            associated_row = find_row_by_f(map, f_work)
            if associated_row && top_score > score_threshold
                associated_row[3] = g_work.number
                temp_map << associated_row
                matched_johnson_numbers << associated_row[0]
            elsif top_score > score_threshold
                temp_map << [nil, f_work.number, f_work.variant, g_work.number]
            else
                temp_map << [nil, nil, nil, g_work.number]
            end
            top_scores << [g_work.id, f_work.id, top_score]
            puts "#{g_work.lines.first.text}\n#{f_work.lines.first.text}\n#{top_score}\n\n"
        end
        map.each do |map_row|
            unless matched_johnson_numbers.include?(map_row[0])
                map_row[3] = nil
                temp_map << map_row
            end
        end
        puts top_scores.inspect
    end

    def find_row_by_j(map, johnson_work_number)
        map.to_a.find do |row|
            row[0] && row[0] == johnson_work_number
        end
    end

    def find_row_by_f(map, franklin_work)
        map.to_a.find do |row|
            row[1] && row[1].to_i == franklin_work.number && row[2] && row[2] == franklin_work.variant
        end
    end

    def match_by_text
        output_file = CSV.open(Rails.root.join('tmp', 'gutenberg_similarities_pair_distance.csv'), 'wb')
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
                score = g_work.text.downcase.pair_distance_similar(f_text.downcase)
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
        update_map
        exit
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
