namespace :emily do
  namespace :data_changes do

    desc 'Add EDA credits to all images'
    task :eda_credits => [:environment] do 
      Image.where{url != nil}.each do |image|
        image.credits += '<br />' unless image.credits.match(/<br ?\/>$/)
        image.credits += '<br />Emily Dickinson Archive<br />http://www.edickinson.org<br />Copyright & Terms of Use:<br />CC BY-NC-ND 3.0<br />http://www.edickinson.org/terms'
        image.save!
      end
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
    end
  end
end
