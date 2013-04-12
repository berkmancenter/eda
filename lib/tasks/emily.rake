namespace :emily do
    namespace :import do
        desc 'Import Franklin ventura files'
        task :ventura, [:dir] => [:environment] do |task, args|
            require Rails.root.join('lib', 'importers', 'franklin_ventura', 'parse_ventura.rb').to_s
            importer = FranklinVenturaImporter.new
            importer.import(args[:dir], 1850, 1860)
        end
    end
end
