require 'csv'
class WorkTEIDumper
    def dump(output_file)
        pbar = ProgressBar.new("Work TEI", Work.count)
        csv = CSV.open(output_file, 'wb')
        csv << ['Work ID', 'Work TEI']
        controller = ApplicationController.new
        Work.all.each do |w|
            controller.with_format(:tei) do 
                tei = controller.render_to_string(
                    partial: 'works/transcriptions/show',
                    locals: { work: w }
                )
                csv << [w.full_id, tei]
                pbar.inc
            end
        end
    end
end

