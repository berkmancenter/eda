require 'csv'
class ImageMetadataDumper
    def dump(output_file)
        pbar = ProgressBar.new("Image Metadata", Image.count)
        csv = CSV.open(output_file, 'wb')
        csv << ['Image ID', 'Metadata Field', 'Metadata Value']
        Image.all.each do |image|
            image.metadata.each do |key, value|
                csv << [image.url, key, value.to_s]
            end
            pbar.inc
        end
    end
end
