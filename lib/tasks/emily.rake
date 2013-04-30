namespace :emily do
    namespace :import do
        desc 'Import Franklin ventura files'
        task :ventura, [:dir] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'franklin_ventura', 'parse_ventura.rb').to_s
            importer = FranklinVenturaImporter.new
            importer.import(args[:dir], 1850, 1865)
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

        desc 'Import TEI file'
        task :tei, [:edition, :number, :variant, :filename] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'tei', 'parse.rb').to_s
            importer = TEIImporter.new
            edition = Edition.find_by_author(args[:edition])
            importer.import(edition, args[:number], args[:variant], args[:filename])
        end

        desc 'Create collections'
        task :collections, [:filename] => [:environment] do |task, args|
            CSV.open(args[:filename], :headers => true)
        end
    end
end
