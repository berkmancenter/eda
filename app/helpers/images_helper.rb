module ImagesHelper
    # a url to a static, web-sized version of this image 
    def preview_url(image)
        return "#{Eda::Application.config.emily['web_image_directory']}/#{image.url}.jpg";
    end

    def large_jpg_url(image)
        "#{Eda::Application.config.emily['image_host']}?FIF=#{Eda::Application.config.emily['image_directory']}/#{image.url}.tif&WID=#{Eda::Application.config.emily['image_download_max_width']}&CVT=jpeg"
    end
end
