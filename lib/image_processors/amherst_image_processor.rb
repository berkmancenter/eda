class AmherstImageProcessor
    def process_directory(input_dir, output_dir, web_image_output_dir)
        queue = Queue.new

        Dir.foreach(input_dir) do |filename|
            extension = File.extname(filename)
            base = File.basename(filename, extension)
            full_path = "#{input_dir}/#{filename}"
            if File.directory?(full_path) && filename[0] != '.'
                process_directory(full_path, output_dir, web_image_output_dir)
            elsif File.file?(full_path) && extension == '.jpg'
                queue << lambda { process_image(full_path, "#{output_dir}/#{input_dir.split('/').last.gsub(':', '-')}-#{base}.tif", web_image_output_dir) }
            end
        end
        work_queue!(queue)
    end

    def work_queue!(queue)
        threads = []
        processor_count = `cat /proc/cpuinfo | grep processor | wc -l`.to_i

        ([processor_count - 2, 1].max).times do
            threads << Thread.new do
                until queue.empty?
                    work_unit = queue.pop(true) rescue nil
                    if work_unit
                        work_unit.call
                    end
                end
            end
        end
        threads.each { |t| t.join }
    end

    def process_directory_for_web(input_dir, output_dir)
        queue = Queue.new

        Dir.foreach(input_dir) do |filename|
            extension = File.extname(filename)
            base = File.basename(filename, extension)
            full_path = "#{input_dir}/#{filename}"
            puts full_path
            if File.directory?(full_path) && filename[0] != '.'
                process_directory_for_web(full_path, output_dir)
            elsif File.file?(full_path) && extension == '.tif'
                queue << lambda { web_version(full_path, "#{output_dir}/#{base}.jpg") }
            end
        end
        work_queue!(queue)
    end

    def process_image(input_file, output_file, web_image_output_dir)
        width, height = `identify -format "%wx%h" "#{input_file}"`.split('x').map(&:to_i)
        output_dir, output_filename = File.split(output_file)
        extension = File.extname(output_file)
        base = File.basename(output_file, extension)

        #3763
        #3859
        tiny_double_images = [
            'asc-13602-1',
            'asc-15834-2',
        ]
        if (height > 3750 && width > height) || tiny_double_images.include?(base)
            if File.exists?("#{output_dir}/#{base}-0.tif") || File.exists?("#{output_dir}/#{base}-1.tif")
                puts %Q|"#{output_dir}/#{base}-01.tif" exists|
            else
                `convert "#{input_file}" -crop 2x1@ +adjoin +repage "#{output_dir}/#{base}.tmp.jpg"`
                [0,1].each do |i|
                    `convert "#{output_dir}/#{base}.tmp-#{i}.jpg" +repage -define tiff:tile-geometry=256x256 -compress jpeg "ptif:#{output_dir}/#{base}-#{i}.tif"`
                    #web_version(output_file, "#{web_image_output_dir}/#{base}-#{i}.jpg")
                end
                `rm #{output_dir}/#{base}.tmp*`
            end
        else
            if File.exists?(output_file)
                puts "#{output_file} exists"
            else
                `convert "#{input_file}" +repage -define tiff:tile-geometry=256x256 -compress jpeg "ptif:#{output_file}"` 
            end
            #web_version(output_file, "#{web_image_output_dir}/#{base}.jpg")
        end

    end

    def web_version(input_file, output_file)
        `convert "#{input_file}[1]" -resize 500x800 #{output_file}` unless File.exists?(output_file)
    end
end
