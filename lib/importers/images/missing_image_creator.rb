class MissingImageCreator
    def create
        imageless_works.each do |work|
            puts "creating page for imageless work: #{work.number} #{work.variant}"
            create_work_page_without_image(work)
        end
    end

    def imageless_works
        Work.all.select{|w| w.image_set.empty?}
    end

    def create_work_page_without_image(work)
        image = Image.new
        work.image_set << image
        work.save!
    end
end
