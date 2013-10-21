class AmherstImageUrlFinder
    def find(mets_directory, image_directory)
    end

    def parse_image_filename(filename)
        pattern = /^asc-(?<asc>\d+)-(?<page>\d+)(-(?<subpage>0|1))?$/
        return filename.match(patten).named_captures
    end
end
