class VassarImageImporter
    def import(directory)
        puts "Importing Vassar images"
        collection = Collection.create!(name: 'Vassar Special Collections')
        collection.metadata = {
            'URL' => 'http://specialcollections.vassar.edu/',
            'Long Name' => 'Archives and Special Collections Library, Vassar College, Poughkeepsie, NY',
            'Code' => 'VSC'
        }
        total_files = Dir.entries(directory).count
        pbar = ProgressBar.new('Vassar', total_files)
        Dir.open(directory).each_with_index do |filename, i|
            next if filename[0] == '.'
            image_url = File.basename(filename, File.extname(filename))
            image = Image.new(
                :title => "Vassar - #{image_url}",
                :url => image_url,
                :credits => 'Vassar credits',
                :metadata => {
                    'Imported' => Time.now.to_s,
                }
            )
            collection << image
        end
        collection.save!
    end
end
