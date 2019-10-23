class AddNewCollections < ActiveRecord::Migration[5.2]
  def up
    collection = Collection.create(name: 'Dumbarton Oaks, Harvard University')
    collection.metadata = {
      'URL': 'https://www.doaks.org/research/library-archives',
      'Long Name': 'Dumbarton Oaks Research Library and Collections, Rare Book Collection. Washington, D.C.',
      'Code': 'DBO',
    }
    collection.level_order_position = 4
    collection.save!

    collection = Collection.create(name: 'Jones Library')
    collection.metadata = {
      'URL': 'https://www.joneslibrary.org/211/Special-Collections',
      'Long Name': 'Jones Library Special Collections. Amherst, MA',
      'Code': 'JL',
    }
    collection.level_order_position = 6
    collection.save!

    collection = Collection.create(name: 'The Morgan Library & Museum')
    collection.metadata = {
      'URL': 'https://www.themorgan.org/',
      'Long Name': 'The Morgan Library & Museum. New York, NY',
      'Code': 'MLM',
    }
    collection.level_order_position = 8
    collection.save!

    collection = Collection.create(name: 'New York Public Library')
    collection.metadata = {
      'URL': 'http://www.nypl.org/',
      'Long Name': 'New York Public Library, Berg Collection, and Archives and Manuscripts. New York, NY',
      'Code': 'NYPL',
    }
    collection.level_order_position = 9
    collection.save!

    collection = Collection.create(name: 'The Rosenbach')
    collection.metadata = {
      'URL': 'https://rosenbach.org/',
      'Long Name': 'The Rosenbach of the Free Library of Philadelphia. Philadelphia, PA',
      'Code': 'RFLP',
    }
    collection.level_order_position = 10
    collection.save!

    ['Dumbarton Oaks, Harvard University',
     'Jones Library',
     'The Morgan Library & Museum',
     'New York Public Library',
     'The Rosenbach'].map{|name| add_collection_to_editions(name)}
  end

  def add_collection_to_editions(name)
    Edition.is_public.each do |edition|
      parent = edition.image_set.descendants.where(name: 'Other Images')

      raise ::ArgumentError, 'edition_set_parent_name not found' if parent.empty?
      parent = parent.first
      image_set = ImageSet.new(name: name)
      image_set.parent = parent
      image_set.save!
    end
  end

  def drop_collection_from_editions(name)
    Edition.is_public.each do |edition|
      edition.image_set.descendants.where(name: name).destroy_all
    end
  end

  def down
    Collection.where(name: ['Dumbarton Oaks, Harvard University',
                            'Jones Library',
                            'The Morgan Library & Museum',
                            'New York Public Library',
                            'The Rosenbach']).destroy_all

    ['Dumbarton Oaks, Harvard University',
     'Jones Library',
     'The Morgan Library & Museum',
     'New York Public Library',
     'The Rosenbach'].map{|name| drop_collection_from_editions(name)}
  end
end
