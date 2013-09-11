require 'csv'
class ImageToTranscriptionConnector
    def create_map(output_map_file)
        pbar = ProgressBar.new('Images', Image.count)
        franklin = Edition.find_by_work_number_prefix('F')
        johnson = Edition.find_by_work_number_prefix('J')
        gutenberg = Edition.find_by_work_number_prefix('G')
        map = CSV.open(output_map_file, 'wb')
        map << ['image_url', 'johnson', 'franklin', 'franklin_variant', 'gutenberg']
        Image.all.each do |image|
            pbar.inc
            next unless image.metadata
            if image.metadata['Identifiers']
                works = works_for_amherst(image, franklin, johnson)
            elsif image.metadata['Label']
                works = works_for_harvard(image, franklin, johnson)
            elsif image.metadata['Identifier (Johnson Poem #)']
                works = works_for_bpl(image, johnson)
            end
            next unless works
            works.each do |w|
                case w.edition
                    when franklin
                        map << [image.url, nil, w.number, w.variant, nil]
                    when johnson
                        map << [image.url, w.number, nil, nil]
                end
            end
        end
    end

    def works_for_amherst(image, franklin, johnson)
        works = []
        franklin_pattern = /Franklin # ?(\d+[; 0-9]*)/
        johnson_pattern = /Johnson Poems # ?([; 0-9]+)$/
        amherst_pattern = /Amherst Manuscript # ?(?<part>(set |fascicle ))?(?<number>[0-9; ]*)/
        location_pattern = /Box (?<box>\d+) Folder (?<folder>\d+)/
        holder_id_pattern = /(\d+)(-(\d+)(\/(\d+))?)?/
        image_url_pattern = /asc-\d+-(\d+)-(0|1)/
        # To match Amherst images, find all with same sheet number and order by
        # franklin number, then guess
        match = image.metadata['Identifiers'].first.match(amherst_pattern)
        return unless match && match[:number]
        manuscript_numbers = match[:number].split(';').map(&:to_i)
        image.metadata['Identifiers'].each do |ident|
            if match = ident.match(franklin_pattern)
                numbers = match[1].split(';').map(&:strip)
                numbers.each do |number|
                    franklin.works.where(number: number).each do |w|
                        if w.metadata && w.metadata['holder_code'] && w.metadata['holder_code'].include?('a')
                            matches = w.metadata['holder_id'].first.match(holder_id_pattern)
                            if matches[1] && matches[3] && matches[5]
                                #puts "#{matches[1]} #{matches[3]} #{matches[5]}"
                                image_url_match = image.url.match(image_url_pattern)
                                if image_url_match && (image_url_match[1] == matches[3] || image_url_match[1] == matches[5])
                                    works << w
                                end
                            elsif matches[1]
                                works << w
                            end
                        end
                    end
                end
            elsif match = ident.match(johnson_pattern)
                if match[1]
                    numbers = match[1].split(';').map(&:to_i)
                    #johnson.works.where(number: numbers).each do |w| end
                end
            end
        end
        works
    end

    def works_for_harvard(image, franklin, johnson)
        output = []
        franklin_numbers = image.metadata['Label'].scan(/Fr(\d{1,4})(\D|$)/).flatten.map(&:to_i).delete_if{|i| i == 0}
        johnson_numbers = image.metadata['Label'].scan(/J(\d{1,4})(\D|$)/)
        call_number_pattern = /ms_am_1118_3_(\d{1,3})_\d{4}/
        call_number_matches = image.url.match(call_number_pattern)
        if call_number_matches
            works = franklin.works.where(number: franklin_numbers).all
            output = works.select do |w|
                w.metadata['holder_id'] &&
                    w.metadata['holder_code'] &&
                    w.metadata['holder_code'].first == 'h' &&
                    w.metadata['holder_id'].first.to_i == call_number_matches[1].to_i
            end
        end
        return output
    end

    def works_for_bpl(image, johnson)
        works = []
        johnson_key = 'Identifier (Johnson Poem #)'
        pattern = /\d+/
        if image.metadata && image.metadata[johnson_key]
            works << johnson.works.find_by_number(image.metadata[johnson_key].to_i)
        end
        works.compact
    end

    def connect(image_to_work_map_file, work_map_file)
        work_map = CSV.open(work_map_file, headers: true)
        pbar = ProgressBar.new("Connecting", CSV.open(image_to_work_map_file).readlines.count)
        CSV.foreach(image_to_work_map_file, headers: true) do |row|
            works = []
            if row['franklin'] && row['franklin_variant']
                works = all_works(work_map, {
                    'franklin' => row['franklin'],
                    'franklin_variant' => row['franklin_variant']
                })
            elsif row['johnson']
                works = all_works(work_map, { 'johnson' => row['johnson'] })
            elsif row['gutenberg']
                works = all_works(work_map, { 'gutenberg' => row['gutenberg'] })
            else
                puts 'stuff' + row.inspect
                exit
            end
            works.each do |work|
                work.image_set << Image.find_by_url(row['image_url'])
            end
            pbar.inc
        end
    end

    def all_works(map, select_hash)
        works = []
        work_row = find_row(map, select_hash)
        return works unless work_row
        franklin = Edition.find_by_work_number_prefix('F')
        johnson = Edition.find_by_work_number_prefix('J')
        gutenberg = Edition.find_by_work_number_prefix('G')
        if work_row['franklin'] && work_row['franklin_variant']
            works += franklin.works.where(number: work_row['franklin'].to_i, variant: work_row['franklin_variant']).all
        elsif work_row['franklin']
            works += franklin.works.where(number: work_row['franklin'].to_i).all
        end
        if work_row['johnson']
            works += johnson.works.where(number: work_row['johnson'].to_i).all
        end
        if work_row['gutenberg']
            works += gutenberg.works.where(number: work_row['gutenberg'].to_i).all
        end
        puts work_row.inspect
        works
    end

    def find_row(table, select_hash)
        selected_row = nil
        table.each do |row|
            if select_hash.keys.all?{ |header| row[header].to_i == select_hash[header].to_i && row[header].to_i != 0 }
                selected_row = row
                puts 'found'
                break
            end
        end
        selected_row
    end
end
