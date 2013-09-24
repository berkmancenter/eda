class BPLImageProcessor
    def process_directory(input_dir, output_dir, web_image_output_dir)
        queue = Queue.new

        Dir.foreach(input_dir) do |filename|
            extension = File.extname(filename)
            base = File.basename(filename, extension)
            full_path = "#{input_dir}/#{filename}"
            if File.directory?(full_path) && filename[0] != '.'
                process_directory(full_path, output_dir)
            elsif File.file?(full_path) && extension == '.jpg'
                queue << lambda { process_image(full_path, "#{output_dir}/#{base}.tif", web_image_output_dir) }
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
            if File.directory?(full_path) && filename[0] != '.'
                process_directory_for_web(full_path, output_dir)
            elsif File.file?(full_path) && extension == '.tif'
                queue << lambda { web_version(full_path, "#{output_dir}/#{base}.jpg") }
            end
        end
        work_queue!(queue)
    end

    def process_image(input_file, output_file, web_image_output_dir)
        # Output tiff for deep zooming
        `convert "#{input_file}" -define tiff:tile-geometry=256x256 -compress jpeg "ptif:#{output_file}"`

        puts 'Doing something'
        extension = File.extname(output_file)
        base = File.basename(output_file, extension)
        web_version(output_file, "#{web_image_output_dir}/#{base}.jpg")
    end

    def web_version(input_file, output_file)
        `convert "#{input_file}[1]" -resize 500x800 #{output_file}`
    end
end
