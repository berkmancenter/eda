require 'csv'
class WorkTextDumper
    def dump(output_file)
        pbar = ProgressBar.new("Work Text", Work.count)
        csv = CSV.open(output_file, 'wb')
        csv << ['Work ID', 'Work Text']
        Work.all.each do |work|
            csv << [work.full_id, work.text]
            pbar.inc
        end
    end
end
