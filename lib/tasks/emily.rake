namespace :emily do

    desc 'Process Harvard images to remove color bars and copyright info'
    task :process_harvard_images, [:image_dir, :output_dir] => [:environment] do |t, args|
        HarvardImageProcessor.new.process_directory(args[:image_dir], args[:output_dir])
    end

    namespace :import do

        namespace :transcriptions do
            desc 'Import transcription corrections'
            task :corrections, [:filename] => [:environment] do |task, args|
                CorrectionsImporter.new.import(args[:filename])
            end

            desc 'Import Johnson works'
            task :johnson, [:filename] => [:environment] do |task, args|
                JohnsonImporter.new.import(args[:filename])
            end

            desc 'Import Project Gutenberg works'
            task :gutenberg, [:filename] => [:environment] do |task, args|
                GutenbergImporter.new.import(args[:filename])
            end

            desc 'Import Franklin ventura files'
            task :franklin, [:directory, :start_year, :end_year] => [:environment] do |task, args|
                start_year = args[:start_year] || 1850
                end_year = args[:end_year] || 1886
                FranklinVentura::Importer.new.import(args[:directory], start_year.to_i, end_year.to_i)
            end
        end

        namespace :images do 
            desc 'Import image instances from METS records'
            task :harvard, [:directory] => [:franklin, :environment] do |task, args|
                HarvardImageImporter.new.import(args[:directory])
            end

            desc 'Import Amherst images'
            task :amherst => [:environment] do
            end

            desc "Import images from BPL's Flickr"
            task :bpl => [:environment] do |t|
                BPLFlickrImporter.new.import
            end

            desc 'Import Library of Congress images'
            task :loc => [:environment] do
                # These don't exist yet
            end
        end

        desc 'Import BYU Lexicon'
        task :lexicon, [:filename] => [:environment] do |task, args|
            LexiconImporter.new.import(args[:filename])
        end

        desc 'Import TEI file'
        task :tei, [:edition, :number, :variant, :filename] => [:environment] do |task, args|
            edition = Edition.find_by_author(args[:edition])
            TEIImporter.new.import(edition, args[:number], args[:variant], args[:filename])
        end

        desc 'Import minimum content necessary to test'
        task :test_data, [:data_directory] => [:environment] do |t, args|
            Rake::Task["emily:import:transcriptions:franklin"].execute({:directory => args[:data_directory] + '/franklin_ventura', :start_year => 1862, :end_year => 1862})
            Rake::Task["emily:import:images:harvard"].execute({:directory => args[:data_directory] + '/mets'})
        end
    end
end
