require 'csv'
class HarvardImageImporter
    def import(directory, johnson_franklin_map, max_images = nil, test = false)
        puts "Importing Harvard images"
        collection = Collection.create!(:name => 'Harvard Collection', :metadata => {'Library' => 'Houghton'})
        editions = Edition.where(:author => ['Thomas H. Johnson', 'R. W. Franklin'])
        image_count = 0
        total_files = Dir.entries(directory).count
        map = CSV.open(Eda::Application.config.emily['data_directory'] + '/image_work_map.csv', 'wb')
        map << ['Image URL', 'Work ID']

        Dir.open(directory).each_with_index do |filename, i|
            puts "File #{i} of #{total_files}"
            next if filename[0] == '.'
            next if max_images && image_count >= max_images
            file = File.open("#{directory}/#{filename}")
            doc = Nokogiri::XML(file)
            doc.remove_namespaces!

            # Create sheet group and add to edition
            sheet_groups = editions.map{|e| new_sheet_group(e, doc)} unless test

            doc.css('structMap div[TYPE=PAGE]').each do |page|
                file_id = page.css('fptr')[1]['FILEID']
                image_url = doc.at(%Q|file[ID="#{file_id}"]|).at('FLocat')['href']
                next unless image_url && page['LABEL']
                if match = image_url.match(/(ms_.*)\.jp2/)
                    image_url = match[1]
                else
                    next
                end
                web_file = Rails.root.join('app', 'assets', 'images', Eda::Application.config.emily['web_image_directory'], image_url + '.jpg').to_s
                width, height = `identify -format "%wx%h" "#{web_file}"`.split('x').map(&:to_i) unless test

                image = Image.new(
                    :url => image_url,
                    :credits => 'Harvard credits',
                    :web_width => width,
                    :web_height => height,
                    :metadata => {
                        'Imported' => Time.now.to_s,
                        'Order' => page['ORDER'].to_i,
                        'Order Label' => page['ORDERLABEL'],
                        'Label' => page['LABEL']
                    }
                ) unless test
                image_count += 1

                collection << image unless test

                editions.each_with_index do |edition, i|
                    sheet_groups[i] << image unless test
                    works = works_from_page(edition, page, johnson_franklin_map)
                    if works.empty?
                        map << [image_url, nil]
                        next
                    end
                    works.each do |work|
                        map << [image_url, work.full_id]
                        work.image_set << image unless test
                        work.save! if work.changed? && !test
                    end
                end
            end
            sheet_groups.each(&:save!) unless test
            editions.each(&:save!) unless test
            collection.save! unless test
        end
    end

    def page_has_works?(editions, page, johnson_franklin_map)
        editions.any?{|e| !works_from_page(e, page, johnson_franklin_map).empty? }
    end

    def doc_has_works?(edition, doc, johnson_franklin_map)
        doc.css('structMap div[TYPE=PAGE]').any? do |page|
            !works_from_page(edition, page, johnson_franklin_map).empty?
        end
    end

    def new_sheet_group(edition, doc)
        is = ImageSet.create!(
            :name => doc.at('mets')['LABEL'],
            :editable => false,
            :metadata => {
                'Hollis ID' => doc.at_css('identifier[type="hollis"]').text,
                'URI' => doc.at_css('identifier[type="uri"]').text
            }
        )
        is.move_to_child_of edition.image_set
        is
    end

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
        franklin_numbers = label.scan(/Fr(\d{1,4})(\D|$)/)
        johnson_numbers = label.scan(/J(\d{1,4})(\D|$)/)
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
end
