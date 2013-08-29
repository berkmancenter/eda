class MissingImageCreator
    def create
        iw_edition_groups = imageless_works.group_by{|w| w.edition.id}
        iw_edition_groups.each do |edition_id, works|
            images = []
            edition = Edition.find(edition_id)
            works.each do |work|
                puts "Creating image for imageless work: #{work.edition.work_number_prefix}#{work.number} #{work.variant}"
                image = Image.new
                work.image_set = ImageSet.create
                work.image_set << image
                images << image
                work.save!
            end
            edition.image_set = edition.image_set.duplicate
            edition.save!
            images.each do |image|
                edition.image_set << image
            end
        end
    end

    def imageless_works
        Work.joins("INNER JOIN setts AS s1 ON s1.id = works.image_set_id AND s1.type = 'ImageSet' LEFT OUTER JOIN setts AS s2 ON s1.id = s2.parent_id").where(s2: { nestable_id: nil }).readonly(false)
    end
end
