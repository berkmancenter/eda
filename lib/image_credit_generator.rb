class ImageCreditGenerator
    def generate!
            Collection.all.each do |collection|
                collection.all_images.each do |image|
                    credits = %Q|<a href="#{collection.metadata['URL']}">#{collection.metadata['Long Name']}</a>|
                    parent_collection = collection.leaves_containing(image).first.parent
                    credits += "\n#{parent_collection.name}" unless parent_collection == collection.root
                    credits += "\n#{image.title}\n#{pub_history(image)}"
                    image.credits = credits
                    image.save!
                end
            end
    end

    def pub_history(image)
        franklin = Edition.find_by_work_number_prefix('F')
        output = "Publication History\n"
        franklin.works.in_image(image).each do |work|
            output += work.metadata['Publication'].strip + ". #{franklin.short_name} (#{work.full_id}).\n"
        end
        output.strip
    end
end
