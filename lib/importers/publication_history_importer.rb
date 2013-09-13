require 'csv'

class PublicationHistoryImporter
    def import(filename, edition_prefix)
        puts 'Importing publication histories'
        edition = Edition.find_by_work_number_prefix(edition_prefix)
        headers = ['Publication','Day','Month','Year','Pages','Source Variant']
        pbar = ProgressBar.new("Pub History", CSV.readlines(filename).count - 1)
        CSV.foreach(filename, headers: true) do |row|
            pbar.inc
            works = get_works(edition, row)
            row['Month'] ||= 1
            row['Day'] ||= 1
            wa = WorkAppearance.new(
                publication: row['Publication'],
                date: Date.parse("#{row['Year']}-#{row['Month']}-#{row['Day']}"),
            )
            wa.pages = row['Pages'] if row['Pages']
            wa.notes.build(note: row['Notes']) if row['Notes']
            works.each do |w|
                if w.appearances.where(publication: wa.publication, date: wa.date).empty?
                    w.appearances << wa 
                    w.save!
                end
            end
        end
    end

    def get_works(edition, row)
        works = []
        if row['Source Variant'] && match = row['Source Variant'].match(/^[A-Z]*$/)
            variant = match.to_s.chars.to_a
        end
        works = edition.works.where(number: row['Franklin Number'].to_i)
        works = works.where(variant: variant) if variant
        works
    end
end
