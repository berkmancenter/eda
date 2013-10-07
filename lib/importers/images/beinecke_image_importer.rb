require 'csv'
class BeineckeImageImporter
    def import(directory, metadata_csv)
        puts "Importing Beinecke images"
        collection = Collection.create!(name: 'Yale University, Beinecke Rare Book & Manuscript Library')
        total_files = Dir.entries(directory).count
        pbar = ProgressBar.new('Beinecke Images', total_files)
        metadata_csv = CSV.open(metadata_csv, headers: true)
        Dir.open(directory).each_with_index do |filename, i|
            next if filename[0] == '.'
            image_url = File.basename(filename, File.extname(filename))
            metadata = {}
            metadata_csv.each do |row|
                next unless row['image_url'] && row['image_url'].strip == image_url.strip
                row.each do |header, value|
                    next if header == 'image_url' || value.nil?
                    metadata[header] = value
                end
            end
            metadata['Imported'] = Time.now.to_s
            image = Image.new(
                :title => "Yale - #{image_url} - #{metadata['Page']}",
                :url => image_url,
                :credits => 'Beinecke credits',
                :metadata => metadata
            )
            collection << image
            pbar.inc
        end
        collection.save!
    end
end


