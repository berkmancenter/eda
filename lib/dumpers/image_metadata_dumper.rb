require 'csv'
class ImageMetadataDumper
    def dump(output_file)
        csv = CSV.opem(output_file, 'wb')
        csv << ['Image ID', 'Metadata Field', 'Metadata Value']
        Image.all.each do |image|
            image.metadata.each do |key, value|
                csv << [image.url, key, value.to_s]
            end
        end
    end
end
