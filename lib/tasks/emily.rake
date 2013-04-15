namespace :emily do
    namespace :import do
        desc 'Import Franklin ventura files'
        task :ventura, [:dir] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'franklin_ventura', 'parse_ventura.rb').to_s
            importer = FranklinVenturaImporter.new
            importer.import(args[:dir], 1850, 1860)
        end

        desc 'Import Johnson works'
        task :johnson, [:filename] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'johnson', 'parse_johnson.rb').to_s
            importer = JohnsonImporter.new
            importer.import(args[:filename])
        end

        desc 'Create collections'
        task :collections, [:filename] => [:environment] do |task, args|
            CSV.open(args[:filename], :headers => true)
        end
    end
end
