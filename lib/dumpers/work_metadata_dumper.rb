require 'csv'
class WorkMetadataDumper
    def dump(output_file)
        csv = CSV.opem(output_file, 'wb')
        csv << ['Work ID', 'Metadata Field', 'Metadata Value']
        Work.all.each do |work|
            work.metadata.each do |key, value|
                csv << [work.full_id, key, value.to_s]
            end
        end
    end
end
