module ImagesHelper
    # a url to a static, web-sized version of this image 
    def preview_url(image)
        return "#{Eda::Application.config.emily['web_image_directory']}/#{image.url}.jpg";
    end

    def image_group_url(edition, image)
        edition_image_group_url(edition, image.image_groups.find{|ig| ig.root == edition.root_image_group})
    end
end
