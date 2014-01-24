class ImageCreditGenerator
  def generate!
    puts 'Importing Image Credits'
    pbar = ProgressBar.new('Credits', Collection.all.reduce(0){|sum, c| c.all_images.count + sum})
    Collection.all.each do |collection|
      case collection.name
      when 'Amherst College'
        collection.all_images.each do |image|
          url = collection.metadata['URL']
          url = image.metadata['Amherst Location'] if image.metadata['Amherst Location']
          url = "https://acdc.amherst.edu/view/#{image.metadata['Accession Number']}" if image.metadata['Accession Number']
          credits = %Q|<a href="#{url}" target="_blank">#{collection.metadata['Long Name']}</a>|
          parent_collection = collection.leaves_containing(image).first.parent
          credits += "<br />#{parent_collection.name}" unless parent_collection.root?
          credits += "<br />#{image.title}<br /><br />#{pub_history(image)}"
          credits += eda_credits
          image.credits = credits
          image.save!
          pbar.inc
        end
      when "American Antiquarian Society",
        "Beinecke Library",
        "Library of Congress",
        "Smith College Libraries",
        "Vassar Special Collections"
        collection.all_images.each do |i|
          i.credits = collection_link(collection)
          i.credits += smaller_library_credits(i)
          i.credits += "<br />#{pub_history(i)}" unless pub_history(i).empty?
          i.credits += eda_credits
          i.save!
          pbar.inc
        end
      when "Houghton Library"
        collection.all_images.each do |image|
          credits = collection_link(collection)
          parent_collection = collection.leaves_containing(image).first.parent
          credits += "<br />#{parent_collection.name}" unless parent_collection.root?
          credits += "<br />#{image.title}<br />#{pub_history(image)}" unless pub_history(image).empty?
          credits += eda_credits
          image.credits = credits
          image.save!
          pbar.inc
        end
      else
        collection.all_images.each do |image|
          credits = collection_link(collection)
          credits += "<br />#{image.title}<br />#{pub_history(image)}" unless pub_history(image).empty?
          credits += eda_credits
          image.credits = credits
          image.save!
          pbar.inc
        end
      end
    end
  end

  def smaller_library_credits(image)
    "<br />#{image.title}. Library ID: #{image.metadata['Library ID']}<br />"
  end

  def eda_credits
    '<br /><br />Emily Dickinson Archive<br />http://www.edickinson.org<br />Copyright & Terms of Use:<br />CC BY-NC-ND 3.0<br />http://www.edickinson.org/terms'
  end

  def collection_link(collection)
    %Q|<a href="#{collection.metadata['URL']}" target="_blank">#{collection.metadata['Long Name']}</a>|
  end

  def pub_history(image)
    franklin = Edition.find_by_work_number_prefix('F')
    works = franklin.works.in_image(image)
    output = ""
    has_pub_history = works && works.any?{|w| w.metadata['Publications'] && !w.metadata['Publications'].empty?}
    output = "<strong>Publication History</strong><br />" if has_pub_history
    publications = []
    works.each do |work|
      unless work.metadata['Publications'].nil? || work.metadata['Publications'].empty?
        publications <<  work.metadata['Publications'].strip + ". #{franklin.short_name} (#{work.full_id})."
      end
    end
    publications.uniq.each do |pub|
      output += pub + '<br />'
    end
    output += " -<em>History from #{franklin.short_name}</em>" if has_pub_history
    output.strip
  end
end
