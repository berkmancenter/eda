module ImageSetsHelper
    def breadcrumb(image_set)
        links = []
        output = ""
        image_set.ancestors.each do |ancestor|
            links << link_to(ancestor.name, ancestor.root.is_a?(Collection) ? collection_image_set_path(ancestor.root, ancestor) : edition_image_set_path(ancestor.root.editions.first, ancestor))
        end
        top_level = image_set.root.is_a?(Collection) ? link_to('Collections', collections_path) : link_to(image_set.root.editions.first.short_name, edition_image_sets_path(image_set.root.editions.first))
        links.each{|l| output += " - #{sanitize l}"}
        output = "#{top_level} #{output}"
        output
    end

    def image_set_link_url(image)
        if @collection
            puts 'collection'
            edition_image_set_path(@edition, @collection.leaves_containing(image).first)
        elsif page = @edition.image_set.leaves_containing(image).first 
            edition_image_set_path(@edition, page)
        else
            ''
        end
    end
end
