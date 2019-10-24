require 'csv'
class ImageToTranscriptionConnector
    include Rails.application.routes.url_helpers
    def create_map(output_map_file, additional_maps, blank_images_file, lost_works_file)
        pbar = ProgressBar.new('Images', Image.count)
        franklin = Edition.find_by_work_number_prefix('F')
        johnson = Edition.find_by_work_number_prefix('J')
        blank_images = File.readlines(blank_images_file).map(&:strip)
        map = CSV.open(output_map_file, 'wb')
        map << ['image_url', 'J', 'F']
        lost_works = CSV.read(lost_works_file).flatten
        Image.all.each do |image|
            pbar.inc
            next if blank_images.include? image.url
            next unless image.metadata
            if image.metadata['Identifiers']
                #works = works_for_amherst(image, franklin, johnson)
            elsif image.metadata['Label']
                works = works_for_harvard(image, franklin, johnson)
            elsif image.metadata['Identifier (Johnson Poem #)']
                works = works_for_bpl(image, johnson)
            end
            next unless works
            works.each do |w|
                next if lost_works.include?(w.full_id)
                case w.edition
                    when franklin
                        map << [
                            image.url,
                            nil,
                            w.full_id,
                        ]
                    when johnson
                        map << [
                            image.url,
                            w.full_id,
                            nil,
                        ]
                end
            end
        end
        additional_maps.each do |a_map|
            a_map.each do |row|
                next if lost_works.include?(row['F'])
                map << row
            end
        end
    end

    def create_map_to_review(output_map_file, output_map_file_by_edition, additional_maps, blank_images_file, lost_works_file)
        pbar = ProgressBar.new('Review', Image.count)
        franklin = Edition.find_by_work_number_prefix('F')
        johnson = Edition.find_by_work_number_prefix('J')
        blank_images = File.readlines(blank_images_file).map(&:strip)
        map = CSV.open(output_map_file, 'wb')
        map_by_edition = CSV.open(output_map_file_by_edition, 'wb')
        map << ['image_url', 'J', 'F', 'collection', 'link']
        map_by_edition << ['edition', 'link', 'has_image']
        lost_works = CSV.read(lost_works_file).flatten
        Collection.all.each do |collection|
            collection.all_images.each do |image|
                franklin.works.in_image(image).each do |work|
                    image_set = work.image_set.leaves_containing(image).first
                    map << [image.url, nil, work.full_id, collection.name, edition_image_set_url(franklin, image_set)]
                end
                pbar.inc
            end
        end

        pbar = ProgressBar.new('By Edition', ImageSet.count)
        Edition.all.each do |edition|
            edition.image_set.leaves.each do |image_set|
                if image_set.image && !edition.works.in_image(image_set.image).empty?
                    map_by_edition << [edition.short_name, edition_image_set_url(edition, image_set), !(image_set.image.url.nil? || image_set.image.url.empty?)]
                end
                pbar.inc
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
                work_am_manuscript_nums = [w.metadata['holder_id'].values_at(*indices)].flatten
                next if (work_am_manuscript_nums.map(&:to_i) & image_am_manuscript_nums.map(&:to_i)).empty?
                url_match = image.url.match(image_url_pattern)
                work_am_manuscript_nums.each do |w_man_num|
                    holder_id_match = w_man_num.match(holder_id_pattern)
                    if holder_id_match && holder_id_match[3] && holder_id_match[5]
                        url_suffixes = sheet_id_to_image_url("#{holder_id_match[3]}/#{holder_id_match[5]}")
                        if url_suffixes.nil?
                            #puts "holder is weird: #{holder_id_match.inspect} - #{image.url} - #{w.full_id} - #{w.title}"
                        elsif url_match && url_match[1] && url_suffixes.include?(url_match[1])
                            works << w
                        end
                    elsif holder_id_match && holder_id_match[3]
                        url_suffixes = sheet_id_to_image_url(holder_id_match[3])
                        if url_suffixes.nil?
                            puts "holder is weird: #{holder_id_match.inspect} - #{image.url} - #{w.full_id} - #{w.title}"
                        elsif url_match && url_match[1] && url_suffixes.include?(url_match[1])
                            works << w
                        end
                    else
                        #puts "holder is weird: #{w_man_num} - #{image.url} - #{w.full_id} - #{w.metadata['holder_id']} - #{w.title}"
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
            '17/18' => ['17-1', '18-0', '18-1', '19'],
            '2/3' => ['2-1', '3-0', '3-1', '4-0'],
            '4/5' => ['4-1', '5-0', '5-1', '6-0'],
            '6/7' => ['6-1', '7-0', '7-1', '8-0'],
            '8/9' => ['8-1', '9-0', '9-1', '10-0'],
            '10/11' => ['10-1', '11-0', '11-1', '12-0'],
            '12/13' => ['12-1', '13-0', '13-1', '14-0'],
            '14/15' => ['14-1', '15-0', '15-1', '16-0'],
            '16/17' => ['16-1', '17-0', '17-1', '18-0'],
            '1' => ['1', '2-0'],
            '2' => ['2-1', '3-0'],
            '3' => ['3-1', '4-0'],
            '4' => ['4-1', '5-0'],
            '5' => ['5-1', '6-0'],
            '6' => ['6-1', '7-0'],
            '7' => ['7-1', '8-0'],
            '8' => ['8-1', '9-0'],
            '9' => ['9-1', '10-0'],
            '10' => ['10-1', '11-0'],
            '11' => ['11-1', '12-0'],
            '12' => ['12-1', '13-0'],
            '13' => ['13-1', '14-0'],
            '14' => ['14-1', '15-0'],
        }
        map[sheet_id]
    end

    def works_for_harvard(image, franklin, johnson)
        output = []
        franklin_numbers = image.metadata['Label'].scan(/Fr(\d{1,4})(\D|$)/).flatten.map(&:to_i).delete_if{|i| i == 0}
        johnson_numbers = image.metadata['Label'].scan(/J(\d{1,4})(\D|$)/)
        call_number_pattern = /ms_am_1118_\d_(?<subcode>B|L|H)?(?<number>\d{1,3})/
        call_number_matches = image.url.match(call_number_pattern)
        return output unless call_number_matches
        # Try to pick a variant by matching holder information
        works = franklin.works.where(number: franklin_numbers).all
        output = works.select do |w|
            matches = (w.metadata['holder_id'] &&
                       w.metadata['holder_code'] &&
                       w.metadata['holder_code'].first == 'h' &&
                       w.metadata['holder_id'].first.to_i == call_number_matches[:number].to_i)
            if call_number_matches[:subcode]
                matches = matches && call_number_matches[:subcode].downcase == w.metadata['holder_subcode'].first.downcase
            end
            matches
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
            select_hash = Hash[row.headers.zip(row.fields)].delete_if{|k, v| v.nil? || ['image_url', 'position_in_work_set', 'position_in_image_set'].include?(k)}
            works = []
            works = all_works(work_map, select_hash)
            works.each do |work|
                image_set = work.image_set.duplicate
                image_set << Image.find_by_url(row['image_url'])
                work.image_set = image_set
                work.save(validate: false)
            end
            work_map.rewind
            pbar.inc
        end
    end

    def all_works(map, select_hash)
        works = []
        work_row = find_row(map, select_hash)
        if work_row.nil?
            select_hash.each do |edition_prefix, work_full_id|
                works << Work.find_by_full_id(work_full_id)
            end
        else
            works_hash = Hash[work_row.headers.zip(work_row.fields)].delete_if{|k, v| v.nil?}
            works_hash.each do |edition_prefix, work_full_id|
                works << Work.find_by_full_id(work_full_id)
            end
        end
        works.compact
    end

    def find_row(table, select_hash)
        selected_row = nil
        table.each do |row|
            if select_hash.keys.all? do |header|
                row[header] == select_hash[header]
            end
                selected_row = row
                break
            end
        end
        selected_row
    end
end
