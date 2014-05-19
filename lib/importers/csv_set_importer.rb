require 'csv'

class CSVSetImporter
  def import_into_collection(set_info)
    parent = Collection.find_by_name(set_info['collection_parent_name'])
    raise ::ArgumentError, 'collection_parent_name not found' unless parent
    set = ImageSet.create(name: set_info['name'])
    set.move_to_child_of parent
    if set_info['collection_next_sibling_name']
      next_sibling = parent.children.find_by_name(set_info['collection_next_sibling_name'])
      raise ::ArgumentError, 'collection_next_sibling_name not found' unless next_sibling
      set.level_order_position = next_sibling.position_in_level
    end
    set.save!
  end

  def import_into_editions(set_info)
    Edition.is_public.each do |edition|
      parent = edition.image_set.descendants.where(
        name: set_info['edition_set_parent_name']
      )
      raise ::ArgumentError, 'edition_set_parent_name not found' if parent.empty?
      set = ImageSet.create(name: set_info['name'])
      parent = parent.first
      set.move_to_child_of parent
      if set_info['edition_set_next_sibling_name']
        next_sibling = parent.children.find_by_name(set_info['collection_next_sibling_name'])
        raise ::ArgumentError, 'collection_next_sibling_name not found' unless next_sibling
        set.level_order_position = next_sibling.position_in_level
      end
      set.save!
    end
  end

  def import(csv_file)
    CSV.foreach(csv_file, headers: true) do |set_info|
      import_into_collection(set_info) if set_info['collection_parent_name']
      import_into_editions(set_info) if set_info['edition_set_parent_name']
    end
  end
end
