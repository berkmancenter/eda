require 'csv'
class ImageToTranscriptionConnector
    def create_map(output_map_file)
        pbar = ProgressBar.new('Images', Image.count)
        franklin = Edition.find_by_work_number_prefix('F')
        johnson = Edition.find_by_work_number_prefix('J')
        map = CSV.open(output_map_file, 'wb')
        map << ['image_url', 'J', 'F', 'position_in_work_set', 'position_in_image_set']
        Image.all.each do |image|
            pbar.inc
            next unless image.metadata
            if image.metadata['Identifiers']
                works = works_for_amherst(image, franklin, johnson)
            elsif image.metadata['Label']
                #works = works_for_harvard(image, franklin, johnson)
            elsif image.metadata['Identifier (Johnson Poem #)']
                #works = works_for_bpl(image, johnson)
            end
            next unless works
            works.each do |w|
                case w.edition
                    when franklin
                        map << [
                            image.url,
                            nil,
                            w.full_id,
                            nil,
                            franklin.image_set.leaves_containing(image).first.position_in_level + 1
                        ]
                    when johnson
                        map << [
                            image.url,
                            w.full_id,
                            nil,
                            nil,
                            johnson.image_set.leaves_containing(image).first.position_in_level + 1
                        ]
                end
            end
        end
    end

    def works_for_amherst(image, franklin, johnson)
        works = []
        johnson_pattern = /Johnson Poems # ?([; 0-9]+)$/
        location_pattern = /Box (?<box>\d+) Folder (?<folder>\d+)/
        works += franklin_works_for_amherst(image, franklin)
        image.metadata['Identifiers'].each do |ident|
            if (match = ident.match(johnson_pattern)) && works.empty?
                if match[1]
                    numbers = match[1].split(';').map(&:to_i)
                    works += johnson.works.where(number: numbers).all
                end
            end
        end
        works
    end

    def franklin_works_for_amherst(image, franklin)
        # To match Amherst images, find all with same sheet number and order by
        # franklin number, then guess
        works = []
        holder_id_pattern = /(\d+)(-(\d+)(\/(\d+))?)?/
        image_url_pattern = /asc-\d+-((\d+)-(0|1))/
        franklin_pattern = /Franklin # ?(\d+[; 0-9]*)/
        amherst_pattern = /Amherst Manuscript # ?(?<part>(set |fascicle ))?(?<number>[0-9; ]*)/
        match = image.metadata['Identifiers'].first.match(amherst_pattern)
        return unless match && match[:number]
        image_am_manuscript_nums = match[:number].split(';')
        image.metadata['Identifiers'].each do |ident|
            next unless match = ident.match(franklin_pattern)
            work_numbers = match[1].split(';').map(&:strip)
            franklin.works.where(number: work_numbers).each do |w|
                next unless w.metadata && w.metadata['holder_code']
                indices = w.metadata['holder_code'].each_index.select{|i| w.metadata['holder_code'][i] == 'a'}
                next if indices.empty?
                work_am_manuscript_nums = [w.metadata['holder_id'][*indices]].flatten
                puts 'start'
                puts work_am_manuscript_nums.inspect
                puts image_am_manuscript_nums.inspect
                next if (work_am_manuscript_nums.map(&:to_i) & image_am_manuscript_nums.map(&:to_i)).empty?
                url_match = image.url.match(image_url_pattern)
                puts url_match.inspect
                work_am_manuscript_nums.each do |w_man_num|
                    holder_id_match = w_man_num.match(holder_id_pattern)
                    if holder_id_match && holder_id_match[3] && holder_id_match[5]
                        url_suffixes = sheet_id_to_image_url("#{holder_id_match[3]}/#{holder_id_match[5]}")
                        puts url_match.inspect
                    else
                        puts holder_id_match.inspect
                    works << w
                    end
                end
            end
        end
        works
    end

    def sheet_id_to_image_url(sheet_id)
        map = {
            '1/2' => ['1', '2-0', '2-1', '3-0'],
            '3/4' => ['3-1', '4-0', '4-1', '5-0'],
            '5/6' => ['5-1', '6-0', '6-1', '7-0'],
            '7/8' => ['7-1', '8-0', '8-1', '9-0'],
            '9/10' => ['9-1', '10-0', '10-1', '11-0'],
            '11/12' => ['11-1', '12-0', '12-1', '13-0'],
            '13/14' => ['13-1', '14-0', '14-1', '15-0'],
            '15/16' => ['15-1', '16-0', '16-1', '17-0'],
            '17/18' => ['17-1', '18-0', '18-1', '19']
        }
        map[sheet_id]
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
                work.image_set = work.image_set.duplicate
                work.image_set << Image.find_by_url(row['image_url'])
            end
            work_map.rewind
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
        works
    end

    def find_row(table, select_hash)
        selected_row = nil
        table.each do |row|
            if select_hash.keys.all? do |header|
                #puts "#{row[header]} == #{select_hash[header]}"
                #puts "#{row[header] == select_hash[header]}"
                #puts row.inspect
                #puts select_hash.inspect
                row[header] == select_hash[header]
            end
                selected_row = row
                break
            end
        end
        selected_row
    end
end
