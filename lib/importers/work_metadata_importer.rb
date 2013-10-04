require 'csv'

class WorkMetadataImporter
    def import(filename, edition_prefix)
        edition = Edition.find_by_work_number_prefix(edition_prefix)
        headers = ['Time Frame','Year','Source Person','Source Type','Source Notes','Recipient']
        pbar = ProgressBar.new("Metadata", CSV.readlines(filename).count - 1)
        CSV.foreach(filename, headers: true) do |row|
            pbar.inc
            work = get_work(row, edition)
            if work.nil?
                puts "Not found: #{row['Franklin Number']} #{row['Variant']}"
                next
            end
            headers.each do |header|
                work.metadata[header] = row[header]
            end
        end
    end

    def get_work(row, edition)
        edition.works.where(number: row['Franklin Number'], variant: row['Variant'].gsub(/[^A-Z\.0-9]/, '')).where(secondary_source: row['Variant'][0] == '[').first if row['Franklin Number'] && row['Variant']
    end
end
