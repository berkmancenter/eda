require 'csv'
class TranscriptionConnecter
    COLUMN_NAME_TO_PREFIX_MAP = {
        :johnson => 'J',
        :franklin => 'F'
    }

    def generate_similarity_map(edition_1, edition_2)
        filename = File.join(Eda::Application.config.emily['data_directory'],
            "#{edition_1.work_number_prefix}_#{edition_2.work_number_prefix}_similarities.csv")

        output_file = CSV.open(filename, 'wb')

        if edition_1.works.count > edition_2.works.count
            tmp = edition_1
            edition_1 = edition_2
            edition_2 = tmp
        end
        puts
        pbar1 = ProgressBar.new("Gener Texts", edition_2.works.count)
        edition_2_texts = {}
        output = {}
        edition_2.works.each do |work|
            edition_2_texts[work.full_id] = work.text
            pbar1.inc
        end

        puts
        pbar2 = ProgressBar.new("Gener Scores", edition_1.works.count * edition_2.works.count)
        edition_1.works.each do |g_work|
            output[g_work.full_id] = {}
            edition_2_texts.each do |f_id, f_text|
                score = g_work.text.downcase.pair_distance_similar(f_text.downcase)
                output[g_work.full_id][f_id] = score
                pbar2.inc
            end
        end

        output_file << [''] + edition_2_texts.keys
        output.each do |g_id, fs|
            output_file << [g_id] + fs.values
        end
        output_file.close
        CSV.open(filename, converters: [:numeric])
    end
    
    def similarity_map(edition_1, edition_2)
        csv = nil
        possible_filenames = [
            File.join(Eda::Application.config.emily['data_directory'],
            "#{edition_1.work_number_prefix}_#{edition_2.work_number_prefix}_similarities.csv"),
            File.join(Eda::Application.config.emily['data_directory'],
            "#{edition_2.work_number_prefix}_#{edition_1.work_number_prefix}_similarities.csv")
        ]

        possible_filenames.each do |filename|
            if File.exists? filename
                csv = CSV.open(filename, converters: [:numeric])
                break
            end
        end

        if csv
            return csv
        else
            return generate_similarity_map(edition_1, edition_2)
        end
    end

    def matching_work_by_text(similarity_map, work, match_edition)
        score_threshold = 0.7714
        matched_work = nil
        similarity_map.each_with_index do |row, i|
            next if i == 0 || row[0] != work.full_id
            scores = row[1..-1]
            top_score = scores.sort.last
            f_work = Work.find_by_full_id(similarity_map[0][scores.index(top_score) + 1])
            if f_work && top_score > score_threshold
                matched_work = f_work
                break
            end
        end
        unless matched_work
            similarity_map_by_col = similarity_map.transpose
            similarity_map_by_col.each_with_index do |col, i|
                next if i == 0 || col[0] != work.full_id
                scores = col[1..-1]
                top_score = scores.sort.last
                f_work = Work.find_by_full_id(similarity_map_by_col[0][scores.index(top_score) + 1])
                if f_work && top_score > score_threshold
                    matched_work = f_work
                    break
                end
            end
        end
        matched_work
    end


    def pull_variant(pub_string)
        variant_matches = pub_string.scan(/<em>([A-Z])<\/em>(]? principal)?/)
        return if variant_matches.empty?
        principal = variant_matches.find{|v| !v[1].nil? && v[1].match(/principal/)}
        if principal
            return principal[0]
        else
            return variant_matches.first.first
        end
    end

    def pull_variant_from_johnson(publications)
        johnson_pattern = /<em>Poems<\/em> \(1955\)/
        publications.each do |pub|
            if pub.match(johnson_pattern)
                return pull_variant(pub)
            end
        end
    end

    def connect(work_map)
        puts 'Connecting Transcriptions'
        map = CSV.open(work_map, 'wb')
        headers = []
        Edition.all.each{|e| headers << e.work_number_prefix }
        map << headers
        franklin = Edition.find_by_work_number_prefix('F')
        edition_publication_map = {
            'J' => /\(J(\d+)\)/,
            'P90-' => /<em>Poems<\/em> \(1890\)/,
            'P91-' => /<em>Poems<\/em> \(1891\)/,
            'P96-' => /<em>Poems<\/em> \(1896\)/,
        }
        similarity_maps = {
            'P90-' => similarity_map(franklin, Edition.find_by_work_number_prefix('P90-')).read,
            'P91-' => similarity_map(franklin, Edition.find_by_work_number_prefix('P91-')).read,
            'P96-' => similarity_map(franklin, Edition.find_by_work_number_prefix('P96-')).read
        }

        pbar = ProgressBar.new("Connecting", franklin.works.count)
        franklin.works.each do |work|
            pbar.inc
            row = CSV::Row.new(headers, [])
            row['F'] = work.full_id
            unless work.metadata && work.metadata['Publications']
                map << row
                next
            end
            work.metadata['Publications'].each do |pub|
                variant = work.variants.count == 0 ? work.variant : pull_variant(pub)
                edition_publication_map.each do |e, pattern|
                    next unless match = pub.match(pattern)
                    case e
                    when 'J'
                        variant = pull_variant_from_johnson(work.metadata['Publications'])
                        variant = work.variant if work.variants.count == 0
                        johnson_number = match[1]
                        row['J'] = e + johnson_number if variant == work.variant
                    when 'P90-', 'P91-', 'P96-'
                        edition = Edition.find_by_work_number_prefix(e)
                        matching_work = matching_work_by_text(similarity_maps[e], work, edition) if edition
                        row[e] = matching_work.full_id if matching_work
                    end
                end
            end
            map << row
        end
    end
end
