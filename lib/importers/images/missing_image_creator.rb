class MissingImageCreator
    def create
        imageless_works.each do |work|
            puts "Creating image for imageless work: #{work.edition.work_number_prefix}#{work.number} #{work.variant}"
            create_image_for_imageless_work(work)
        end
    end

    def imageless_works
        Work.joins("INNER JOIN setts AS s1 ON s1.id = works.image_set_id AND s1.type = 'ImageSet' LEFT OUTER JOIN setts AS s2 ON s1.id = s2.parent_id").where(s2: { nestable_id: nil }).readonly(false)
    end

    def create_image_for_imageless_work(work)
        image = Image.new
        work.image_set << image
        work.edition.image_set << image
        work.save!
    end
end
