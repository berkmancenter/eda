require 'csv'

class PublicationHistoryImporter
    def import(filename, edition_prefix)
        edition = Edition.find_by_work_number_prefix(edition_prefix)
        headers = ['Publication','Day','Month','Year','Pages','Source Variant']
        CSV.foreach(filename, headers: true) do |row|
            works = get_works(row)
            works.each do |work|
                work.note = row['Notes']
                work.save!
            end
        end
    end

    def get_works(row)
        Work.where(number: row['Franklin Number'].to_i)
    end
end
