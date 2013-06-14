class HarvardImageProcessor
    def process_directory(input_dir, output_dir)

        queue = Queue.new
        threads = []
        processor_count = `cat /proc/cpuinfo | grep processor | wc -l`.to_i

        Dir.foreach(input_dir) do |filename|
            extension = File.extname(filename)
            base = File.basename(filename, extension)
            full_path = "#{input_dir}/#{filename}"
            if File.directory?(full_path) && filename[0] != '.'
                process_directory(full_path, output_dir)
            elsif File.file?(full_path) && extension == '.jp2'
                queue << lambda { process_image(full_path, "#{output_dir}/#{base}.tif") }
            end
        end

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

    def process_image(input_file, output_file)
        width, height = `identify -format "%wx%h" "#{input_file}"`.split('x').map(&:to_i)
        first_white_x = `convert "#{input_file}" -crop 0x1+0+#{height / 2 - 10} txt:- | grep 'FFFFFF' | head -n 1 | grep -o '^[0-9]*'`.to_i
        last_white_x = `convert "#{input_file}" -crop 0x1+0+#{height / 2 - 10} txt:- | grep 'FFFFFF' | tail -n 1 | grep -o '^[0-9]*'`.to_i

        # Look for the copyright stuff at the bottom
        black_ys = `convert "#{input_file}" -crop 1x0+#{width / 2}+0 -modulate 67,0 -level 50%,50% txt:- | grep '000000' | grep -o '[0-9][0-9]*:'`.split.map!(&:to_i).reverse!
        last_y = height
        height_of_bottom = black_ys.take_while{|y| out = y == last_y - 1; last_y = y; out }.count

        # Pull off color bar
        if first_white_x < 10
            edge_width = "+#{last_white_x + 10}"
        else
            edge_width = "-#{width - first_white_x + 10}"
        end

        # Pull off copyright crap
        crop_bottom = "-#{[0, height_of_bottom - 100].max}"

        `convert "#{input_file}" -crop #{edge_width}#{crop_bottom} +repage -define tiff:tile-geometry=256x256 -compress jpeg "ptif:#{output_file}"`
    end
end
