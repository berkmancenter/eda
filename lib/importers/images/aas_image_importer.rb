require 'csv'
class AASImageImporter
    def import(directory, metadata_csv)
        puts "Importing AAS images"
        collection = Collection.create!(name: 'American Antiquarian Society')
        total_files = Dir.entries(directory).count
        pbar = ProgressBar.new('AAS Images', total_files)
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
                :title => "AAS - #{image_url}",
                :url => image_url,
                :credits => 'AAS credits',
                :metadata => metadata
            )
            collection << image
            pbar.inc
        end
        collection.save!
    end
end
