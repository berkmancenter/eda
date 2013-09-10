require 'csv'
class ImageToTranscriptionConnector
    def create_map(output_map_file)
        franklin = Edition.find_by_work_number_prefix('F')
        johnson = Edition.find_by_work_number_prefix('J')
        gutenberg = Edition.find_by_work_number_prefix('G')
        map = CSV.open(output_map_file, 'wb')
        map << ['image_url', 'johnson', 'franklin', 'franklin_variant', 'gutenberg']
        Image.all.each do |image|
            if image.metadata['Identifiers']
                works = works_for_amherst(image, franklin, johnson)
            elsif image.metadata['Label']
                works = works_for_harvard(image.metadata['Label'], franklin, johnson)
            elsif image.metadata['Identifier (Johnson Poem #)']
                works = works_for_bpl(image.metdata['Identifier (Johnson Poem #)'], johnson)
            end
        end
    end

    def works_for_amherst(image, id, franklin, johnson)
        works = []
        franklin_pattern = /Franklin # ?(\d+[; 0-9]*)/
        johnson_pattern = /Johnson Poems # ?(\d+[; 0-9]*)/
        amherst_pattern = /Amherst Manuscript # ?(?<part>(set |fascicle ))?(?<number>[0-9; ]*)/
        location_pattern = /Box (?<box>\d+) Folder (?<folder>\d+)/
        # To match Amherst images, find all with same sheet number and order by
        # franklin number, then guess
        match = images.metadata['Identifiers'].first.match(amherst_pattern)
        return unless match && match[:number]
        manuscript_numbers = match[:number].split(';').map(&:to_i)
        images.metadata['Identifiers'].each do |ident|
            if match = ident.match(franklin_pattern)
                numbers = match[1].split(';').map(&:strip)
                numbers.each do |number|
                    franklin.where(number: number).each do |w|
                        w.metadata['holder_code'].include?('a')
                    end
                end
            elsif match = ident.match(johnson_pattern)
            end
        end
    end

    def works_for_harvard(id, franklin, johnson)
        franklin_numbers = label.scan(/Fr(\d{1,4})(\D|$)/)
        johnson_numbers = label.scan(/J(\d{1,4})(\D|$)/)
    end

    def works_for_bpl(id, johnson)
        johnson_key = 'Identifier (Johnson Poem #)'
        pattern = /\d+/
    end

    def connect(image_to_work_map_file, work_map_file)
        work_map = CSV.open(work_map_file)
        CSV.foreach(image_to_work_map_file) do |row|
            if row[:franklin] && row[:franklin_variant]
                works = all_works(work_map, {
                    franklin: row[:franklin],
                    franklin_variant: row[:franklin_variant]
                })
            elsif row[:johnson]
                works = all_works(work_map, { johnson: row[:johnson] }
            elsif row[:gutenberg]
                works = all_works(work_map, { gutenberg: row[:gutenberg] }
            end
            works.each do |work|
                work.image_set << Image.find_by_url(row[:image_url])
            end
        end
    end

    def all_works(map, select_hash)
        work_row = find_row(work_map, select_hash)
        franklin = Edition.find_by_work_number_prefix('F')
        johnson = Edition.find_by_work_number_prefix('J')
        gutenberg = Edition.find_by_work_number_prefix('G')
        works = []
        if work_row[:franklin] && work_row[:franklin_variant]
            works << franklin.works.where(number: work_row[:franklin], variant: work_row[:franklin_variant]).all
        end
        if work_row[:johnson]
            works << johnson.works.where(number: work_row[:johnson]).all
        end
        if work_row[:gutenberg]
            works << gutenberg.works.where(number: work_row[:gutenberg]).all
        end
        works
    end

    def find_row(table, select_hash)
        selected_row = nil
        table.each do |row|
            if select_hash.keys.all?{ |header| row[header] == select_hash[header] }
                selected_row = row
                break
            end
        end
        selected_row
    end


    # From BPL
    def get_work(edition, johnson_number, johnson_franklin_map)
        editions.each do |edition|
            work = get_work(edition, johnson_number, j_f_map)
            next unless work
            # Add image to edition group
            image_for_edition_group = edition.root_image_group.image_group_images.build(
                :position => edition.root_image_group.image_group_images.count
            )
            image_for_edition_group.image = image
        end
        johnson_key = 'Identifier (Johnson Poem #)'
        johnson = edition.author == 'Thomas H. Johnson'
        work = nil
        #TODO: Do BPL images have multiple works in a single image?
        if johnson
            work = edition.works.find_by_number(johnson_number)
        else
            franklin_number = johnson_franklin_map[johnson_number].to_i
            work = edition.works.find_by_number(franklin_number) if franklin_number
        end
        work
    end

    # From BPL
    def create_work_pages!(edition, works, image, image_for_group)
        works.each do |work|
            page = edition.pages.new
            page.image = image_for_group
            page.work = work
            unless work.image_group
                work.image_group = ImageGroup.new(:name => "Images for #{work.title}")
            end
            work_group_image = work.image_group.image_group_images.new(:position => work.image_group.image_group_images.count)
            work_group_image.image = image
            work.save!
            page.save!
        end
    end

    # From Harvard
    def works_from_page(edition, page, johnson_franklin_map)
        label = page['LABEL']
        return [] unless label
        johnson = false
        if edition.author == 'Thomas H. Johnson'
            johnson = true
            f_j_map = Hash[CSV.read(johnson_franklin_map, {:headers => true, :converters => :integer}).to_a[1..-1]].invert
        end
        works = []
        call_number_pattern = /ms_am_1118_3_(\d{1,3})_\d{4}/
            call_number = page.css('fptr').first['FILEID']
        call_number_matches = call_number.match(call_number_pattern)
        work_numbers = johnson ? johnson_numbers : franklin_numbers
        work_numbers.each do |work_number|
            work_number = work_number[0].to_i
            next unless work_number
            if edition.works.where(:number => work_number).count > 1
                work = edition.works.where(:number => work_number).all.find do |w|
                    call_number_matches &&
                        w.metadata['holder_id'] &&
                        w.metadata['holder_code'] &&
                        w.metadata['holder_code'] == 'H' &&
                        w.metadata['holder_id'] == call_number_matches[1]
                end
                #puts "Multiple works in '#{edition.name}' with number #{work_number}"
                puts "Didn't pick a variant for #{work_number} with '#{call_number_matches}' from #{call_number}" unless work
            end
            # Just pull the first one
            works << (work ? work : edition.works.find_by_number(work_number))
        end
        works.compact!
        works
    end
    def harvard
        works = works_from_page(edition, page, johnson_franklin_map)
        if works.empty?
            map << [image_url, nil]
        end
        works.each do |work|
            map << [image_url, work.full_id]
            work.image_set << image unless test
            work.save! if work.changed? && !test
        end
    end
end
