namespace :emily do
    namespace :import do
        desc 'Import Franklin ventura files'
        task :ventura, [:directory, :start_year, :end_year] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'franklin_ventura', 'parse_ventura.rb').to_s
            start_year = args[:start_year] || 1850
            end_year = args[:end_year] || 1882
            importer = FranklinVenturaImporter.new
            importer.import(args[:directory], start_year.to_i, end_year.to_i)
        end

        desc 'Import Johnson works'
        task :johnson, [:filename] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'johnson', 'parse_johnson.rb').to_s
            importer = JohnsonImporter.new
            importer.import(args[:filename])
        end

        desc 'Import BYU Lexicon'
        task :lexicon, [:filename] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'lexicon', 'parse_lexicon.rb').to_s
            importer = LexiconImporter.new
            importer.import(args[:filename])
        end

        desc 'Import Project Gutenberg works'
        task :gutenberg, [:filename] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'gutenberg', 'parse_gutenberg.rb').to_s
            importer = GutenbergImporter.new
            importer.import(args[:filename])
        end

        desc 'Import image URLs'
        task :images, [:filename] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'houghton_images', 'image_importer.rb').to_s
            ImageImporter.new.import(args[:filename])
        end

        desc 'Import TEI file'
        task :tei, [:edition, :number, :variant, :filename] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'tei', 'parse.rb').to_s
            importer = TEIImporter.new
            edition = Edition.find_by_author(args[:edition])
            importer.import(edition, args[:number], args[:variant], args[:filename])
        end

        desc 'Import METS records'
        task :mets, [:directory] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'mets', 'parse_mets.rb').to_s
            importer = MetsImporter.new
            importer.import(args[:directory])
        end

        desc 'Import minimum content to test'
        task :test_data, [:data_directory] => [:environment] do |t, args|
            Rake::Task["emily:import:ventura"].execute({:directory => args[:data_directory] + '/franklin_ventura', :start_year => 1860, :end_year => 1862})
            Rake::Task["emily:import:mets"].execute({:directory => args[:data_directory] + '/mets'})
            Rake::Task["emily:import:images"].execute({:filename => args[:data_directory] + '/images.csv'})
        end

        desc 'Create collections'
        task :collections, [:filename] => [:environment] do |task, args|
            CSV.open(args[:filename], :headers => true)
        end
    end
end
