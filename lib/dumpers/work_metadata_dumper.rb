require 'csv'
class WorkMetadataDumper
    def dump(output_file)
        pbar = ProgressBar.new("Work Metadata", Work.count)
        csv = CSV.open(output_file, 'wb')
        csv << ['Work ID', 'Metadata Field', 'Metadata Value']
        Work.all.each do |work|
            work.metadata.each do |key, value|
                csv << [work.full_id, key, value.to_s]
            end
            pbar.inc
        end
    end
end
