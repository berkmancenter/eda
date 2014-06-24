require 'tempfile'

class ZipImageImporter

  CSV_HEADER_FIELDS = [
    'collection_name',
    'collection_parent_name',
    'collection_next_sibling_name',
    'edition_set_parent_name',
    'edition_set_next_sibling_name',
    'title',
    'url',
    'credits',
    'work_ids'
  ]

  def import(zip_filename, image_output_dir = nil)

    Zip::File.open(zip_filename) do |zip_file|
      sets_entry = zip_file.glob('sets.csv')

      unless sets_entry.empty?
        sets_entry = sets_entry.first
        sets_csv = Tempfile.new('sets')
        path = sets_csv.path
        sets_csv.close!
        sets_entry.extract(path)
        CSVSetImporter.new.import(path)
      end

      images_entry = zip_file.glob('images.csv')
      raise ::LoadError, 'Zip file must contain images.csv' if images_entry.empty?
      images_entry = images_entry.first

      images_dir_entry = zip_file.glob('images')
      if images_dir_entry.empty? || images_dir_entry.first.name != 'images/'
        raise ::LoadError, 'Zip file must contain images directory'
      end
      images_dir_entry = images_dir_entry.first

      csv = CSV.parse(images_entry.get_input_stream.read, headers: true)

      csv.each do |row|
        metadata_headers = csv.headers - CSV_HEADER_FIELDS
        metadata = Hash[metadata_headers.zip(row.values_at(*metadata_headers))]
        image = Image.create(
          title: row['title'],
          url: row['url'],
          credits: row['credits'],
          metadata: metadata
        )

        import_into_collection(image, row) if row['collection_parent_name']
        import_into_editions(image, row) if row['edition_set_parent_name']

        if row['work_ids']
          work_ids = row['work_ids'].split(',').map(&:strip)
          work_ids.each do |work_id|
            work = Work.find_by_full_id(work_id)
            raise ::ArgumentError, "Work #{work_id} not found" unless work
            work.image_set << image
          end
        end

      end
    end
  end

  def import_into_collection(image, image_info)
    collection = Collection.find_by_name(image_info['collection_name'])
    raise ::ArgumentError, 'collection_name not found' unless collection

    parent = collection.self_and_descendants.find_by_name(image_info['collection_parent_name'])
    raise ::ArgumentError, 'collection_parent_name not found' unless parent

    image_set = ImageSet.new
    image_set.image = image
    image_set.save!
    image_set.move_to_child_of parent

    if image_info['collection_next_sibling_name']
      next_sibling = parent.children.find_by_name(image_info['collection_next_sibling_name'])
      unless next_sibling
        # In case the image set is getting its name from its contained image
        next_sibling = parent.children.all.find{|c| c.name == image_info['collection_next_sibling_name']}
      end
      raise ::ArgumentError, "collection_next_sibling_name '#{image_info['collection_next_sibling_name']}' not found" unless next_sibling
      image_set.level_order_position = next_sibling.position_in_level
    end
    image_set.save!
  end

  def import_into_editions(image, image_info)
    Edition.is_public.each do |edition|
      parent = edition.image_set.descendants.where(
        name: image_info['edition_set_parent_name']
      )

      raise ::ArgumentError, 'edition_set_parent_name not found' if parent.empty?
      parent = parent.first

      image_set = parent << image

      if image_info['edition_set_next_sibling_name']
        next_sibling = parent.children.find{|c| c.name == image_info['collection_next_sibling_name']}
        raise ::ArgumentError, "collection_next_sibling_name '#{image_info['collection_next_sibling_name']}' not found" unless next_sibling
        image_set.level_order_position = next_sibling.position_in_level
      end
      image_set.save!
    end
  end
end
