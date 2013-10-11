namespace :emily do

    desc 'Rename images to match holder ids'
    task :rename_images => [:environment] do |t|
        directory = '/home/justin/Desktop/previews/'
        include ImageRenamer
        Dir.entries(directory).each do |f|
            next unless File.file?(File.join(directory, f))
            url = f.sub('.jpg', '')
            image = Image.find_by_url(url)
            if image.nil?
                puts url
            end
            next if image.nil? || image.url.nil?
            new_name = new_filename(image)
            File.rename(File.join(directory, f), File.join(directory, new_name))
        end
    end

    desc 'Convert missing image csv'
    task :convert_missing, [:input_file, :output_file] => [:environment] do |t, args|
        include ImageRenamer
        require 'csv'
        input_file = args[:output_file] || File.join(Eda::Application.config.emily['data_directory'], 'work_missing_images_manual_map.csv')
        output_file = args[:output_file] || File.join(Eda::Application.config.emily['data_directory'], 'manual_map.csv')
        output_file = CSV.open(output_file, 'wb')
        output_file << ['image_url', 'J', 'F']
        map = {}
        Image.all.each do |image|
            map[new_filename(image)] = image.url
        end
        CSV.foreach(input_file, headers: true) do |row|
            if row['image_filename'] && map[row['image_filename'].strip]
                output_file << [map[row['image_filename'].strip], nil, row['work_id']]
            end
        end
    end

    namespace :generate do
        desc 'Process Harvard images to remove color bars and copyright info'
        task :harvard_images, [:input_dir, :output_dir, :web_image_output_dir] => [:environment] do |t, args|
            output_dir = args[:output_dir] || Eda::Application.config.emily['image_directory']
            web_image_output_dir = args[:web_image_output_dir] || Rails.root.join('app', 'assets', 'images', 'previews')
            HarvardImageProcessor.new.process_directory(args[:input_dir], output_dir, web_image_output_dir)
        end

        desc 'Process Amherst images to cut double images into singles'
        task :amherst_images, [:input_dir, :output_dir, :web_image_output_dir] => [:environment] do |t, args|
            input_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/amherst'
            output_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/amherst_output'
            web_image_output_dir = args[:web_image_output_dir] || Rails.root.join('app', 'assets', 'images', 'previews')
            AmherstImageProcessor.new.process_directory(input_dir, output_dir, web_image_output_dir)
            AmherstImageProcessor.new.process_directory_for_web(output_dir, web_image_output_dir)
        end

        desc 'Process missing Amherst images to cut double images into singles'
        task :missing_amherst_images, [:input_dir, :output_dir, :web_image_output_dir] => [:environment] do |t, args|
            input_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/amherst_missing'
            output_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/amherst_missing_output'
            web_image_output_dir = args[:web_image_output_dir] || Rails.root.join('app', 'assets', 'images', 'previews')
            MissingAmherstImageProcessor.new.process_directory(input_dir, output_dir, web_image_output_dir)
        end

        desc 'Process BPL images to create tifs'
        task :bpl_images, [:input_dir, :output_dir, :web_image_output_dir] => [:environment] do |t, args|
            input_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/bpl'
            output_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/bpl_output'
            web_image_output_dir = args[:web_image_output_dir] || Rails.root.join('app', 'assets', 'images', 'previews')
            BPLImageProcessor.new.process_directory(input_dir, output_dir, web_image_output_dir)
            #BPLImageProcessor.new.process_directory_for_web(output_dir, web_image_output_dir)
        end

        desc 'Process LOC images to create tifs'
        task :loc_images, [:input_dir, :output_dir, :web_image_output_dir] => [:environment] do |t, args|
            input_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/loc'
            output_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/loc_output'
            web_image_output_dir = args[:web_image_output_dir] || Rails.root.join('app', 'assets', 'images', 'previews')
            GeneralImageProcessor.new.process_directory(input_dir, output_dir, web_image_output_dir)
            GeneralImageProcessor.new.process_directory_for_web(output_dir, web_image_output_dir)
        end

        desc 'Process LOC images to create tifs'
        task :aas_images, [:input_dir, :output_dir, :web_image_output_dir] => [:environment] do |t, args|
            input_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/aas'
            output_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/aas_output'
            web_image_output_dir = args[:web_image_output_dir] || Rails.root.join('app', 'assets', 'images', 'previews')
            GeneralImageProcessor.new.process_directory(input_dir, output_dir, web_image_output_dir)
            GeneralImageProcessor.new.process_directory_for_web(output_dir, web_image_output_dir)
        end

        desc 'Process Beinecke images to create tifs'
        task :beinecke_images, [:input_dir, :output_dir, :web_image_output_dir] => [:environment] do |t, args|
            input_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/beinecke'
            output_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/beinecke_output'
            web_image_output_dir = args[:web_image_output_dir] || Rails.root.join('app', 'assets', 'images', 'previews')
            GeneralImageProcessor.new.process_directory(input_dir, output_dir, web_image_output_dir)
            #GeneralImageProcessor.new.process_directory_for_web(output_dir, web_image_output_dir)
        end

        desc 'Process Smith images to create tifs'
        task :smith_images, [:input_dir, :output_dir, :web_image_output_dir] => [:environment] do |t, args|
            input_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/smith'
            output_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/smith_output'
            web_image_output_dir = args[:web_image_output_dir] || Rails.root.join('app', 'assets', 'images', 'previews')
            GeneralImageProcessor.new.process_directory(input_dir, output_dir, web_image_output_dir)
            #GeneralImageProcessor.new.process_directory_for_web(output_dir, web_image_output_dir)
        end

        desc 'Process Vassar images to create tifs'
        task :vassar_images, [:input_dir, :output_dir, :web_image_output_dir] => [:environment] do |t, args|
            input_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/vassar'
            output_dir = args[:output_dir] || Eda::Application.config.emily['data_directory'] + '/images/vassar_output'
            web_image_output_dir = args[:web_image_output_dir] || Rails.root.join('app', 'assets', 'images', 'previews')
            GeneralImageProcessor.new.process_directory(input_dir, output_dir, web_image_output_dir)
            #GeneralImageProcessor.new.process_directory_for_web(output_dir, web_image_output_dir)
        end

        desc 'Create web-ready images for page turning'
        task :web_images, [:input_dir, :output_dir] => [:environment] do |t, args|
            output_dir = args[:output_dir] || Rails.root.join('app', 'assets', 'images', 'previews')
            HarvardImageProcessor.new.process_directory_for_web(args[:input_dir], output_dir)
        end

        desc 'Create images to works map'
        task :images_to_transcriptions_map, [:output_map_file, :blank_images_file, :lost_works_file] => [:environment] do |task, args|
            require 'csv'
            output_map_file = args[:output_map_file] || File.join(Eda::Application.config.emily['data_directory'], 'image_to_work_map.csv')
            blank_images_file = args[:blank_images_file] || File.join(Eda::Application.config.emily['data_directory'], 'blank_amherst_images.txt')
            lost_works_file = args[:lost_works_file] || File.join(Eda::Application.config.emily['data_directory'], 'lost_works.csv')
            additional_maps = [
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'image_csvs', 'aas.csv'), headers: true),
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'image_csvs', 'beinecke.csv'), headers: true),
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'image_csvs', 'smith.csv'), headers: true),
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'image_csvs', 'vassar.csv'), headers: true),
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'amherst_image_to_work_map.csv'), headers: true),
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'manual_map.csv'), headers: true)
            ]
            ImageToTranscriptionConnector.new.create_map(output_map_file, additional_maps, blank_images_file, lost_works_file)
        end

        desc 'Create images to works map after everything has been imported'
        task :images_to_transcriptions_map_for_review, [:output_map_file, :output_map_file_by_edition, :blank_images_file, :lost_works_file] => [:environment] do |task, args|
            require 'csv'
            output_map_file = args[:output_map_file] || File.join(Eda::Application.config.emily['data_directory'], 'image_to_work_map_to_review.csv')
            output_map_file_by_edition = args[:output_map_file_by_edition] || File.join(Eda::Application.config.emily['data_directory'], 'image_to_work_map_to_review_by_edition.csv')
            blank_images_file = args[:blank_images_file] || File.join(Eda::Application.config.emily['data_directory'], 'blank_amherst_images.txt')
            lost_works_file = args[:lost_works_file] || File.join(Eda::Application.config.emily['data_directory'], 'lost_works.csv')
            additional_maps = [
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'image_csvs', 'aas.csv'), headers: true),
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'image_csvs', 'beinecke.csv'), headers: true),
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'image_csvs', 'smith.csv'), headers: true),
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'image_csvs', 'vassar.csv'), headers: true),
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'amherst_image_to_work_map.csv'), headers: true),
                CSV.open(File.join(Eda::Application.config.emily['data_directory'], 'manual_map.csv'), headers: true)
            ]
            ImageToTranscriptionConnector.new.create_map_to_review(output_map_file, output_map_file_by_edition, additional_maps, blank_images_file, lost_works_file)
        end

        desc 'Connect all existing transcriptions together'
        task :transcriptions_map, [:map_file, :publication_history_file] => [:environment] do |task, args|
            map_file = args[:map_file] || File.join(Eda::Application.config.emily['data_directory'], 'work_map.csv')
            TranscriptionConnecter.new.connect(map_file)
        end

        desc 'Generate image credits'
        task :image_credits => [:environment] do |task, args|
            ImageCreditGenerator.new.generate!
        end
    end

    namespace :connect do
        desc 'Connect images to editions'
        task :images_to_editions  => [:environment] do |task|
            ImageToEditionConnector.new.connect
        end

        desc 'Connect variants to recipients'
        task :variants_to_recipients, [:map_file, :output_file] => [:environment] do |task, args|
            require 'csv'
            map_file = args[:map_file] || File.join(Eda::Application.config.emily['data_directory'], 'franklin_recipients.csv')
            output_file = args[:output_file] || File.join(Eda::Application.config.emily['data_directory'], 'variants_to_recipients.csv')
            franklin = Edition.find_by_work_number_prefix('F')
            csv = CSV.read(map_file)
            output_file = CSV.open(output_file, 'wb')
            output_file << ['work_number', 'best_candidate_variant', 'recipient', 'questionable', 'variant_scores']
            pbar = ProgressBar.new('Connect', csv.length)
            csv.each do |row|
                pattern = Amatch::LongestSubstring.new(row.last.downcase.strip)
                works = franklin.works.where(number: row.first)
                pbar.inc
                if works.count == 1
                    output_file << [row.first, works.first.variant, row.last, 'false', nil]
                    next
                end
                candidate_scores = works.map do |v|
                    if v.metadata && v.metadata['Note']
                        [v.variant, (pattern.match(v.metadata['Note'].downcase) / row.last.length.to_f).round(4)]
                    else
                        [v.variant, 0.0]
                    end
                end
                candidate_scores = candidate_scores.sort_by{|s| 1 - s.last}
                candidate_scores.delete_if{|s| s.last == 0}
                best_candidate = candidate_scores.empty? ? nil : candidate_scores.max_by(&:last).first
                questionable = candidate_scores.empty? ? nil : (candidate_scores.max_by(&:last).last < 0.6)
                output_file << [row.first, best_candidate, row.last, questionable, candidate_scores.map{|a| a.join(': ')}.join(', ')]
            end
        end

        desc 'Connect images to works using the map'
        task :images_to_transcriptions, [:image_to_work_map_file, :work_map_file] => [:environment] do |task, args|
            image_to_work_map_file = args[:image_to_work_map_file] || File.join(Eda::Application.config.emily['data_directory'], 'image_to_work_map.csv')
            work_map_file = args[:map_file] || File.join(Eda::Application.config.emily['data_directory'], 'work_map.csv')
            ImageToTranscriptionConnector.new.connect(image_to_work_map_file, work_map_file)
        end
    end

    namespace :find_errors do
        desc 'Check all transcriptions for errors'
        task :transcriptions => [:environment] do |task|
            Edition.all.each do |edition|
                TranscriptionErrorFinder.new.find_errors(edition.works)
            end
        end

        desc 'Find variants pointing at same images'
        task :variant_images, [:output_file] => [:environment] do |task, args|
            require 'csv'
            output_file = args[:output_file] || Rails.root.join('tmp', 'variant_images.csv')
            csv = CSV.open(output_file, 'wb')
            csv << ['image_url', 'work_ids']
            edition = Edition.find_by_work_number_prefix('F')
            works = edition.works.all.group_by(&:number)
            works.each do |number, variants|
                next unless variants.count > 1
                duplicated_images = variants.map{|w| w.image_set.all_images}.flatten.group_by(&:id).select{|id, is| is.count > 1}.values.flatten.uniq
                duplicated_images.each do |i|
                    work_ids = edition.works.in_image(i).map(&:full_id).uniq
                    csv << [i.url, work_ids.join(', ')] if work_ids.length > 1
                end
            end
        end

        desc 'Find works without images'
        task :works_without_images, [:output_file] => [:environment] do |task, args|
            require 'csv'
            output_file = args[:output_file] || Rails.root.join('tmp', 'without_images.csv')
            csv = CSV.open(output_file, 'wb')
            csv << ['work_id', 'holder_info']
            works = Edition.find_by_work_number_prefix('F').works.all.select{|w| !w.secondary_source && w.image_set.all_images.all?{|i| i.url.nil?}}
            works.each do |work|
                metadata = nil
                if work.metadata['holder_code']
                    metadata = work.metadata['holder_code'].zip(work.metadata['holder_subcode'], work.metadata['holder_id']).map{|m| m.join(' ')}.join(', ')
                end
                csv << [work.full_id, metadata]
            end
        end

        desc 'Find works with images that should not have images'
        task :should_not_have_images, [:output_file] => [:environment] do |task, args|
            require 'csv'
            output_file = args[:output_file] || Rails.root.join('tmp', 'should_not_have_images.csv')
        end
    end

    namespace :import do
        desc 'Import work metadata CSV'
        task :metadata, [:filename, :edition_prefix] => [:environment] do |task, args|
            filename = args[:filename] || File.join(Eda::Application.config.emily['data_directory'], 'franklin_metadata.csv')
            edition_prefix = args[:edition_prefix] || 'F'
            WorkMetadataImporter.new.import(filename, edition_prefix)
        end

        desc 'Import library editions'
        task :library_editions => [:environment] do |task|

        end

        desc 'Import work publication history CSV'
        task :publication_history, [:filename, :edition_prefix] => [:environment] do |task, args|
            filename = args[:filename] || File.join(Eda::Application.config.emily['data_directory'], 'franklin_publication_history.csv')
            edition_prefix = args[:edition_prefix] || 'F'
            PublicationHistoryImporter.new.import(filename, edition_prefix)
        end

        desc 'Import Franklin and Johnson recipients'
        task :recipients, [:map_file] => [:environment] do |t, args|
            puts 'Importing Recipients'
            require 'csv'
            map_file = args[:filename] || File.join(Eda::Application.config.emily['data_directory'], 'recipients.csv')
            pbar = ProgressBar.new('Recipients', CSV.readlines(map_file).count)
            CSV.foreach(map_file, headers: true) do |row|
                work = Work.find_by_full_id(row['work_id'])
                if work
                    work.metadata['Recipient'] = row['recipient']
                    work.save!
                else
                    puts "Not found: #{row['work_id']}"
                end
                pbar.inc
            end
        end

        namespace :transcriptions do
            desc 'Import transcription corrections'
            task :revisions, [:filename] => [:environment] do |task, args|
                filename = args[:filename] || File.join(Eda::Application.config.emily['data_directory'], 'tei_corrections', 'EDA-linereading-FranklinV1.xml')
                RevisionImporter.new.import(filename)
            end

            desc 'Import Johnson works'
            task :johnson, [:filename, :max_poems] => [:environment] do |task, args|
                max_poems = args[:max_poems]
                filename = args[:filename] || File.join(Eda::Application.config.emily['data_directory'], 'johnson.txt')
                JohnsonImporter.new.import(filename, max_poems)
            end

            desc 'Import Single Hound'
            task :single_hound, [:filename] => [:environment] do |task, args|
                filename = args[:filename] || File.join(Eda::Application.config.emily['data_directory'], 'single_hound.xml')
                SingleHoundImporter.new.import(filename)
            end

            desc 'Import Project Gutenberg works'
            task :gutenberg, [:filename] => [:environment] do |task, args|
                filename = args[:filename] || File.join(Eda::Application.config.emily['data_directory'], 'gutenberg.html')
                GutenbergImporter.new.import(filename)
            end

            desc 'Import Franklin ventura files'
            task :franklin, [:directory, :start_year, :end_year, :error_check] => [:environment] do |task, args|
                start_year = args[:start_year] || 1850
                end_year = args[:end_year] || 1886
                error_check = args[:error_check] || true
                directory = args[:directory] || File.join(Eda::Application.config.emily['data_directory'], 'franklin_ventura')
                FranklinVentura::Importer.new.import(directory, start_year.to_i, end_year.to_i)
            end

            desc 'Import all transcriptions'
            task :all, [:filename] => [:environment] do |task, args|
                Rake::Task["emily:import:transcriptions:franklin"].execute
                Rake::Task["emily:import:transcriptions:johnson"].execute
                Rake::Task["emily:import:transcriptions:gutenberg"].execute
                Rake::Task["emily:import:transcriptions:single_hound"].execute
                Rake::Task["emily:import:transcriptions:revisions"].execute
            end

        end

        namespace :images do 
            desc 'Import image instances from METS records'
            task :harvard, [:directory, :j_to_f_map_file, :max_images] => [:environment] do |task, args|
                directory = args[:directory] || File.join(Eda::Application.config.emily['data_directory'], 'mets')
                map_file = args[:j_to_f_map_file] || File.join(Eda::Application.config.emily['data_directory'], 'johnson_to_franklin.csv')
                max_images = args[:max_images]
                HarvardImageImporter.new.import(directory, map_file, max_images)
            end

            desc 'Import Amherst images'
            task :amherst, [:image_directory, :mods_directory] => [:environment] do |t, args|
                image_directory = args[:image_directory] || File.join(Eda::Application.config.emily['data_directory'], 'images', 'amherst_output')
                mods_directory = args[:image_directory] || File.join(Eda::Application.config.emily['data_directory'], 'images', 'amherst')
                AmherstImageImporter.new.import(image_directory, mods_directory)
            end

            desc 'Import missing Amherst images'
            task :missing_amherst, [:image_directory, :mods_directory] => [:environment] do |t, args|
                image_directory = args[:image_directory] || File.join(Eda::Application.config.emily['data_directory'], 'images', 'amherst_missing_output')
                MissingAmherstImageImporter.new.import(image_directory)
            end

            desc 'Create missing images'
            task :missing => [:environment] do |task|
                MissingImageCreator.new.create
            end

            desc "Import images from BPL's Flickr"
            task :bpl, [:image_dir, :j_to_f_map_file] => [:environment] do |t, args|
                image_dir = args[:image_directory] || File.join(Eda::Application.config.emily['data_directory'], 'images', 'bpl')
                BPLFlickrImporter.new.import(image_dir)
            end

            desc 'Import Library of Congress images'
            task :loc, [:image_dir] => [:environment] do |t, args|
                image_dir = args[:image_directory] || File.join(Eda::Application.config.emily['data_directory'], 'images', 'loc_output')
                LOCImageImporter.new.import(image_dir)
            end

            desc 'Import AAS images'
            task :aas, [:image_dir] => [:environment] do |t, args|
                image_dir = args[:image_directory] || File.join(Eda::Application.config.emily['data_directory'], 'images', 'aas_output')
                metadata_csv = args[:image_csv] || File.join(Eda::Application.config.emily['data_directory'], 'image_csvs', 'aas_metadata.csv')
                AASImageImporter.new.import(image_dir, metadata_csv)
            end

            desc 'Import Beinecke images'
            task :beinecke, [:image_directory] => [:environment] do |t, args|
                image_dir = args[:image_directory] || File.join(Eda::Application.config.emily['data_directory'], 'images', 'beinecke_output')
                metadata_csv = args[:image_csv] || File.join(Eda::Application.config.emily['data_directory'], 'image_csvs', 'beinecke_metadata.csv')
                BeineckeImageImporter.new.import(image_dir, metadata_csv)
            end

            desc 'Import Smith images'
            task :smith, [:image_directory] => [:environment] do |t, args|
                image_dir = args[:image_directory] || File.join(Eda::Application.config.emily['data_directory'], 'images', 'smith_output')
                SmithImageImporter.new.import(image_dir)
            end

            desc 'Import Vassar images'
            task :vassar, [:image_csv] => [:environment] do |t, args|
                image_dir = args[:image_directory] || File.join(Eda::Application.config.emily['data_directory'], 'images', 'vassar_output')
                VassarImageImporter.new.import(image_dir)
            end

            desc 'Import all images'
            task :all => [:environment] do
                Rake::Task["emily:import:images:aas"].execute
                Rake::Task["emily:import:images:amherst"].execute
                Rake::Task["emily:import:images:missing_amherst"].execute
                Rake::Task["emily:import:images:beinecke"].execute
                Rake::Task["emily:import:images:bpl"].execute
                Rake::Task["emily:import:images:harvard"].execute
                Rake::Task["emily:import:images:loc"].execute
                Rake::Task["emily:import:images:smith"].execute
                Rake::Task["emily:import:images:vassar"].execute
            end
        end

        desc 'Import BYU Lexicon'
        task :lexicon, [:term_file, :definition_file] => [:environment] do |task, args|
            term_file = args[:term_file] || File.join(Eda::Application.config.emily['data_directory'], 'lexicon_terms.csv')
            definition_file = args[:definition_file] || File.join(Eda::Application.config.emily['data_directory'], 'lexicon_defs.csv')
            LexiconImporter.new.import(term_file, definition_file)
        end

        desc 'Import TEI file'
        task :tei, [:edition, :number, :variant, :filename] => [:environment] do |task, args|
            edition = Edition.find_by_author(args[:edition])
            TEIImporter.new.import_from_file(edition, args[:number], args[:variant], args[:filename])
        end

        desc 'Import everything'
        task :everything, [:use_existing_maps] => [:environment] do |task, args|
            if args[:use_existing_maps].nil?
                use_existing_maps = true
            else
                !!use_existing_maps.match(/(true|t|yes|y|1)$/i)
            end
            Rake::Task["emily:import:transcriptions:all"].execute
            Rake::Task["emily:import:metadata"].execute
            Rake::Task["emily:import:publication_history"].execute
            Rake::Task["emily:import:images:all"].execute
            Rake::Task["emily:generate:transcriptions_map"].execute unless use_existing_maps
            Rake::Task["emily:generate:images_to_transcriptions_map"].execute unless use_existing_maps
            Rake::Task["emily:connect:images_to_transcriptions"].execute
            Rake::Task["emily:connect:images_to_editions"].execute
            Rake::Task["emily:import:images:missing"].execute
            Rake::Task["emily:import:lexicon"].execute
            Rake::Task["emily:generate:image_credits"].execute
            Rake::Task["emily:import:recipients"].execute
            Rake::Task["emily:clean_up_metadata"].execute
        end

        desc 'Import minimum content necessary to test'
        task :test_data, [:data_directory] => [:environment] do |t, args|
           # Rake::Task["emily:import:transcriptions:franklin"].execute #({:start_year => 1862, :end_year => 1862, :error_check => false})
           # Rake::Task["emily:import:transcriptions:johnson"].execute #({:max_poems => 300})
            Rake::Task["emily:import:images:harvard"].execute#({:max_images => 500, :test => true})
            Rake::Task["emily:import:images:missing"].execute
            Rake::Task["emily:import:lexicon"].execute
        end
    end

    namespace :dump do
        desc 'Dump work metadata'
        task :work_metadata, [:output_file] => [:environment] do |t, args|
            output_file = args[:output_file] || Rails.root.join('tmp', 'dumped_work_metadata.csv')
            WorkMetadataDumper.new.dump(output_file)
        end

        desc 'Dump work text'
        task :work_text, [:output_file] => [:environment] do |t, args|
            output_file = args[:output_file] || Rails.root.join('tmp', 'dumped_work_text.csv')
            WorkTextDumper.new.dump(output_file)
        end

        desc 'Dump work TEI'
        task :work_tei, [:output_file] => [:environment] do |t, args|
            output_file = args[:output_file] || Rails.root.join('tmp', 'dumped_work_tei.csv')
            WorkTEIDumper.new.dump(output_file)
        end

        desc 'Dump image metadata'
        task :image_metadata, [:output_file] => [:environment] do |t, args|
            output_file = args[:output_file] || Rails.root.join('tmp', 'dumped_image_metadata.csv')
            ImageMetadataDumper.new.dump(output_file)
        end
    end

    desc 'Request everything now so the caches are warm'
    task :warm_cache => [:environment] do |t|
        app = ActionDispatch::Integration::Session.new(Rails.application)
        app.get(Rails.application.routes.url_helpers.works_path)
        Edition.all.each do |edition|
            # Visit the edition work list
            app.get(Rails.application.routes.url_helpers.edition_works_path(edition))
            # Visit all image sets
            edition.image_set.self_and_descendants.each do |image_set|
                puts "getting #{edition.id} - #{image_set.id}"
                app.get(Rails.application.routes.url_helpers.edition_image_set_path(edition, image_set))
            end
        end
    end

    desc 'Clean up metadata'
    task :clean_up_metadata => [:environment] do |t|
        puts 'Cleaning up metadata'
        field_names = {
            "holder_code" => nil,
            "holder_subcode" => nil,
            "Note" => "Notes",
            "holder_id" => nil,
            "Publication" => "Publications",
            "Publications" => nil,
            "notes" => "Additional Notes",
            "fascicle" => nil,
            "fascicle_order" => nil,
            "Source" => nil,
            "Source Code" => nil,
            "set" => "Set"
        }
        pbar = ProgressBar.new('Cleanup', Work.count)
        Work.all.each do |work|
            # Combine fascicle order and facicle
            if work.metadata['fascicle'] && work.metadata['fascicle_order']
                work.metadata['Fascicle'] = "#{work.metadata['fascicle']} - #{work.metadata['fascicle_order']}"
            end

            # Sync date field and "Year"
            if work.metadata['Year'] && work.date.nil?
                work.date = Date.new(work.metadata['Year'], 1, 1)
            end

            metadata = work.metadata.dup
            metadata.each do |field, data|
                if field_names.keys.include? field
                    if field_names[field].nil?
                        work.metadata.delete(field)
                    else
                        work.metadata[field_names[field]] = data
                        work.metadata.delete(field)
                    end
                end
            end

            # Remove redundent metadata
            if work.metadata['Manuscript'] && work.metadata['Notes']
                stripped_manuscript = ActionController::Base.helpers.strip_tags(work.metadata['Manuscript'].strip.downcase)
                stripped_notes = ActionController::Base.helpers.strip_tags(work.metadata['Notes'].strip.downcase)
                work.metadata.delete('Notes') if stripped_manuscript == stripped_notes
            end

            pbar.inc
            work.save!
        end
    end
end
