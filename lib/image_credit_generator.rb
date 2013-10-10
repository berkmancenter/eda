class ImageCreditGenerator
    def generate!
        puts 'Importing Image Credits'
        pbar = ProgressBar.new('Credits', Collection.all.reduce(0){|sum, c| c.all_images.count + sum})
        Collection.all.each do |collection|
            collection.all_images.each do |image|
                credits = %Q|<a href="#{collection.metadata['URL']}" target="_blank">#{collection.metadata['Long Name']}</a>|
                parent_collection = collection.leaves_containing(image).first.parent
                credits += "<br />#{parent_collection.name}" unless parent_collection == collection.root
                credits += "<br />#{image.title}<br />#{pub_history(image)}"
                image.credits = credits
                image.save!
                pbar.inc
            end
        end
    end

    def pub_history(image)
        franklin = Edition.find_by_work_number_prefix('F')
        output = "<strong>Publication History</strong><br />"
        franklin.works.in_image(image).each do |work|
            output += work.metadata['Publication'].strip + ". #{franklin.short_name} (#{work.full_id}).<br />"
        end
        output.strip
    end
end
