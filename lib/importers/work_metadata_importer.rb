require 'csv'

class WorkMetadataImporter
    def import(filename, edition_prefix)
        edition = Edition.find_by_work_number_prefix(edition_prefix)
        headers = ['Time Frame','Year','Source Person','Source Type','Source Notes','Recipient']
        CSV.foreach(filename, headers: true) do |row|
            work = get_work(row)
            if work.nil?
                puts "#{row['Franklin Number']} #{row['Variant']}"
                next
            end
            headers.each do |header|
                work.metadata[header] = row[header]
            end
        end
    end

    def get_work(row)
        Work.find_by_number_and_variant(row['Franklin Number'], row['Variant'].gsub(/[^A-Z\.0-9]/, '')) if row['Franklin Number'] && row['Variant']
    end
end
