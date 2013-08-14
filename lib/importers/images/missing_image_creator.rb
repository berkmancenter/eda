class MissingImageCreator
    def create
        imageless_works.each do |work|
            puts "Creating image for imageless work: #{work.edition.work_number_prefix}#{work.number} #{work.variant}"
            create_image_for_imageless_work(work)
        end
    end

    def imageless_works
        Work.all.select{|w| w.image_set.empty?}
    end

    def create_image_for_imageless_work(work)
        image = Image.new
        work.image_set << image
        work.edition.image_set << image
        work.save!
    end
end
