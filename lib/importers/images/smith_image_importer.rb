class SmithImageImporter
    def import(directory)
        puts "Importing other images"
        collection = Collection.create!(name: 'Smith College, Mortimer Rare Book Room')
        collection.metadata = {
            'URL' => 'http://www.smith.edu/libraries/libs/rarebook/',
            'Long Name' => 'Mortimer Rare Book Room, Smith College, Northampton, MA',
            'Code' => 'SCL'
        }
        total_files = Dir.entries(directory).count
        pbar = ProgressBar.new('Smith', total_files)
        Dir.open(directory).each_with_index do |filename, i|
            next if filename[0] == '.'
            image_url = File.basename(filename, File.extname(filename))
            image = Image.new(
                :title => "Smith - #{image_url}",
                :url => image_url,
                :credits => 'Smith credits',
                :metadata => {
                    'Imported' => Time.now.to_s,
                }
            )
            collection << image
        end
        collection.save!
    end
end
