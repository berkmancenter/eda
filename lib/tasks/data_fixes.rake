namespace :emily do
  namespace :data_changes do

    desc 'Update images from smaller libs'
    task :update_image_metadata, [:input_file] => [:environment] do |t, args|
      require 'csv'
      input_file = args[:input_file] || File.join(Eda::Application.config.emily['data_directory'], 'new_image_names.csv')
      not_found_image_ids = []
      csv = CSV.read(input_file, headers: true)
      csv.each do |row|
        url = row['image_id'].sub(/\.tiff?/i, '').strip
        image = Image.find_by_url(url)
        image = Image.find_by_title(url) unless image
        if image
          image.metadata['Library ID'] = row['library_id']
          image.title = row['description']
          image.save!
        else
          not_found_image_ids << url
          next
        end
      end
      puts "Not found: #{not_found_image_ids}"
    end

    desc 'Add back publication history'
    task :add_publication_history, [:input_file] => [:environment] do |t, args|
      require 'csv'
      input_file = args[:input_file] || File.join(Eda::Application.config.emily['data_directory'], 'publication_history.csv')
      franklin = Edition.find_by_work_number_prefix('F')
      CSV.foreach(input_file) do |row|
        franklin.works.where(number: row[0]).each do |work|
          work.metadata['Publications'] = row[1]
          work.save
        end
      end
    end

    desc 'Sort Amherst'
    task :sort_amherst => [:environment] do |t|
      collection = Collection.find_by_name('Amherst College')
      collection.children.each do |kid|
        kid.name = kid.name.sub(/#(\d)/, '# \1')
        kid.save
      end
      SettSorter.sort_set(collection.id)
    end

    desc 'Sort Smith'
    task :sort_smith => [:environment] do |t|
      collection = Collection.find_by_name('Smith College Libraries')
      SettSorter.sort_set(collection.id)
    end

    desc 'Sort Houghton'
    task :sort_houghton, [:set_labels] => [:environment] do |t, args|
      collection = Collection.find_by_name('Houghton Library')
      set_labels = args[:set_labels] || File.join(Eda::Application.config.emily['data_directory'], 'houghton_set_labels_in_order.txt')
      set_labels_in_order = File.readlines(set_labels).map{|l| l.chomp.strip}
      order = []
      collection.children.each do |kid|
        order[set_labels_in_order.index(kid.name)] = kid.id
      end
      ids_in_order = order.compact
      SettSorter.sort_set(collection.id, ids_in_order)
    end

    desc 'Sort Beinecke'
    task :sort_beinecke => [:environment] do |t|
      collection = Collection.find_by_name('Beinecke Library')
      image_url_order = ['10883042', '10883043', '10883044', '10883048', '10883049-0', '10883049-1', '10883050', '10883051', '10883052-0', '10883052-1', '10883053', '10883054', '10883055b-0', '10883055b-1', '10883056', '10883057', '10883058-0', '10883058-1', '10883059', '10883060', '10891837', '10883061', '10891838', '10883062', '10883063', '10883064', '10883065', '10883066', '10883067b-0', '10883067b-1', '10891839', '10883068', '10883069', '10883070', '10883071', '10883072', '10883073', '10883074', '10883075', '10883076', '10883077', '10883078']
      id_order = image_url_order.map{|url| collection.children.where(nestable_id: Image.find_by_url(url).id).first.id}
      SettSorter.sort_set(Collection.find_by_name('Beinecke Library').id, id_order)
    end

    desc 'Apply data changes'
    task :apply => [:environment] do 
      def remove_image(url)
        image = Image.find_by_url(url)
        return unless image
        image.url = nil
        image.save!
        ImageSet.where(nestable_id: image.id).each do |is|
          is.parent_id = nil
          is.save!
        end
      end

      def fix_amherst_order(image_set)
        ImageSet.find(image_set).leaves.first.move_right.move_right.move_right
      end

      def replace_works_image_set(work_full_id, new_image_urls)
        work = Work.find_by_full_id(work_full_id)
        work.image_set.descendants.destroy_all
        new_image_urls.each do |url|
          work.image_set << Image.find_by_url(url)
        end
        work.save!
      end

      new_work_image_sets = {
        'F676A'    => ['ms_am_1118_3_180_0001', 'ms_am_1118_3_180_0002'],
        'F977A'    => ['ms_am_1118_3_178_0004'],
        'F978A'    => ['ms_am_1118_3_179_0001'],
        'F979A'    => ['ms_am_1118_3_179_0002'],
        'F981A'    => ['ms_am_1118_3_179_0003'],
        'F982A'    => ['ms_am_1118_3_179_0004'],
        'F1187A'   => ['asc-16368-1'],
        'F1299A'   => ["2402705105_4327be1ab3_o", "2403533650_36b015cfe4_o"],
        'F1327A'   => ['2403536638_5516a1ef22_o', '2402708359_4c9841ffc0_o'],
        'F935E'    => [''],
        'F347A'    => ['asc-17618-1', 'asc-17618-2-0'],
        'F195A'    => ['10883054','10883055b-1'],
        'F275A'    => ['10883052-0','10883052-1'],
        'F380A'    => ['10883066','10883067b-1'],
        'F1637A.1' => ['10883073'],
        'F1458A'   => [''],
        'F1672A'   => ['']
      }
      new_work_image_sets.each do |full_id, image_urls|
        replace_works_image_set(full_id, image_urls)
      end

      work = Work.find_by_full_id('F1488B.1')
      work.lines.where{(number >= 0) & (number <= 7)}.each do |line|
        line.number += 1
        line.number += 1 if line.number > 4
        line.save!
      end
      stanza = work.stanzas.find_by_position(1)
      stanza.lines << Line.create(number: 5, text: 'So drunk, he disavows it')
      stanza.save!

      remove_image 'asc-4834-1'
      remove_image 'asc-4834-2'
      fix_amherst_order 72479

      remove_image 'asc-10983-1'
      remove_image 'asc-10983-2'
      fix_amherst_order 73152

      remove_image 'asc-4339-1'
      remove_image 'asc-4339-2'
      fix_amherst_order 72432

      remove_image 'F807B-typed-back'
      remove_image 'F807B-typed-front'
    end
  end
end
