class ImageCreditGenerator
    def generate!
        puts 'Importing Image Credits'
        pbar = ProgressBar.new('Credits', Collection.all.reduce(0){|sum, c| c.all_images.count + sum})
        Collection.all.each do |collection|
            if collection.name == 'Amherst College'
                collection.all_images.each do |image|
                    url = collection.metadata['URL']
                    url = image.metadata['Amherst Location'] if image.metadata['Amherst Location']
                    url = "https://acdc.amherst.edu/view/#{image.metadata['Accession Number']}" if image.metadata['Accession Number']
                    credits = %Q|<a href="#{url}" target="_blank">#{collection.metadata['Long Name']}</a>|
                    credits += "<br />#{image.title}<br />#{pub_history(image)}"
                    image.credits = credits
                    image.save!
                    pbar.inc
                end
            else
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
    end

    def pub_history(image)
        franklin = Edition.find_by_work_number_prefix('F')
        works = franklin.works.in_image(image)
        output = ""
        has_pub_history = works && works.any?{|w| w.metadata['Publication'] && !w.metadata['Publication'].empty?}
        output = "<strong>Publication History</strong><br />" if has_pub_history
        publications = []
        works.each do |work|
            unless work.metadata['Publication'].nil? || work.metadata['Publication'].empty?
                publications <<  work.metadata['Publication'].strip + ". #{franklin.short_name} (#{work.full_id})."
            end
        end
        publications.uniq.each do |pub|
            output += pub + '<br />'
        end
        output += " -<em>History from #{franklin.short_name}</em>" if has_pub_history
        output.strip
    end
end
