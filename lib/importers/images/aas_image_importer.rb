class AASImageImporter
    def import(directory)
        puts "Importing AAS images"
        collection = Collection.create!(name: 'American Antiquarian Society', :metadata => {'Library' => 'AAS'})
        total_files = Dir.entries(directory).count
        pbar = ProgressBar.new('AAS Images', total_files)
        Dir.open(directory).each_with_index do |filename, i|
            next if filename[0] == '.'
            image_url = File.basename(filename, File.extname(filename))
            web_file = Rails.root.join('app', 'assets', 'images', Eda::Application.config.emily['web_image_directory'], image_url + '.jpg').to_s
            width, height = `identify -format "%wx%h" "#{web_file}"`.split('x').map(&:to_i)
            image = Image.new(
                :url => image_url,
                :credits => 'AAS credits',
                :web_width => width,
                :web_height => height,
                :metadata => {
                    'Imported' => Time.now.to_s,
                }
            )
            collection << image
        end
        collection.save!
    end
end
