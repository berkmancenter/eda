require 'csv'
# Mets records get pulled in first
# Go through the image csv, find images with URLs that match filenames, and
# replace with zoom.it URLs
class ImageImporter
    def import(filename)
        CSV.foreach(filename, :headers => true) do |row|
            url = "archival_master/deliverable/#{row['filename'][0..-2]}2"
            image = Image.find_by_url(url)
            image.url = row['url']
            image.full_width = row['width'].to_i
            image.full_height = row['height'].to_i
            image.save
        end
    end
end
