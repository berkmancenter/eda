class LOCImageImporter
    def import(directory)
        puts "Importing Library of Congress images"
        collection = Collection.create!(name: 'Library of Congress, Manuscript Division')
        total_files = Dir.entries(directory).count
        pbar = ProgressBar.new('LOC Images', total_files)
        Dir.open(directory).each_with_index do |filename, i|
            next if filename[0] == '.'
            image_url = File.basename(filename, File.extname(filename))
            image = Image.new(
                :url => image_url,
                :credits => 'LOC credits',
                :metadata => {
                    'Imported' => Time.now.to_s,
                }
            )
            collection << image
            pbar.inc
        end
        collection.save!
    end
end
