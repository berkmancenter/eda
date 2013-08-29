module ImagesHelper
    # a url to a static, web-sized version of this image 
    def preview_url(image)
        return "#{Eda::Application.config.emily['web_image_directory']}/#{image.url}.jpg";
    end
end
