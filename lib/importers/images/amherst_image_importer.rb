class AmherstImageImporter
    def import(image_directory, mods_directory)
        puts 'Importing Amherst Images'
        franklin_pattern = /Franklin # (?<number>\d+)/
        johnson_pattern = /Johnson Poems # (?<number>\d+)/
        amherst_pattern = /Amherst Manuscript # (?<number>\d+)/
        location_pattern = /Box (?<box>\d+) Folder (?<folder>\d+)/
        Dir.entries(image_directory).each do |image_filename|
            next if image_filename[0] == '.'
            call_number = image_filename.match(/asc-\d+/)[0].sub('-', ':')
            mods_filename = mods_directory + '/' + call_number + '/MODS.xml'
            doc = Nokogiri::XML(File.open(mods_filename))
            doc.remove_namespaces!
            image_url = image_filename.match(/(.*).tif/)[1]
            web_file = Rails.root.join('app', 'assets', 'images', Eda::Application.config.emily['web_image_directory'], image_url + '.jpg').to_s
            width, height = `identify -format "%wx%h" "#{web_file}"`.split('x').map(&:to_i)
            image = Image.new(
                url: image_url,
                credits: 'Amherst credits',
                web_width: width,
                web_height: height,
                metadata: {
                    'Imported' => Time.now.to_s,
                    'Identifiers' => doc.css('identifier[type=local]').map(&:text),
                    'Shelf Location' => doc.at('shelfLocator').text,
                    'Title' => doc.at('title').text
                }
            )
            puts image.inspect
        end
    end
end
