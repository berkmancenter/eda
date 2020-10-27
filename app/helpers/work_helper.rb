module WorkHelper
    def render_mod(mod = nil)
        return unless mod
        case mod.type
        when 'Emendation', 'Revision'
            render :partial => "works/transcriptions/mods/#{mod.type.downcase}", :locals => { :mod => mod }
        when 'Division'
            render :partial => "works/transcriptions/mods/#{mod.subtype}_division", :locals => { :mod => mod }
        when 'Alternate'
            render :partial => "works/transcriptions/mods/#{mod.subtype}", :locals => { :mod => mod }
        end
    end

    def render_line(line)
        Rails.logger.debug "[render_line] line: #{line.inspect}"
        output = ''
        line.chars.each_with_index do |char, i|
            Rails.logger.debug "[render_line] line.chars char: #{char}, i: #{i}"
            line.mods_at(i).each do |mod|
                output += render_mod(mod)
                Rails.logger.debug "[render_line] output: [#{output}]"
            end
            output += char
        end
        line.mods_at(line.chars.count).each do |mod|
            Rails.logger.debug "[render_line] line.chars i: #{line.chars.count}"
            output += render_mod(mod)
            Rails.logger.debug "[render_line] output: [#{output}]"
        end
        output
    end

    def render_mod_line_pre_br(line)
        output = ''
        line.chars.each_with_index do |char, i|
            if line.mods_at(i).count > 0
              break
            end
            output += char
        end
        output
    end

    def render_mod_line_post_br(line)
        output = ''
        br = false
        line.chars.each_with_index do |char, i|
          if line.mods_at(i).count > 0
            br = true
          end

          if br
            line.mods_at(i).each do |mod|
                output += render_mod(mod)
            end
            output += char
          end
        end
        line.mods_at(line.chars.count).each do |mod|
            output += render_mod(mod)
        end
        output
    end

    def render_work_result_link(  work )
      raw( "<span class='work-number'>#{work.edition.work_number_prefix}#{work.number} #{work.variant}</span><span class='work-title'>#{work.title}</span>" )
    end

    def lines_in_text_area(work)
        work.lines.count + work.stanzas.count + work.divisions.page_breaks.count
    end

    def flat_text(work)
        with_format(:txt){ render partial: 'works/transcriptions/show', locals: { work: work } }.gsub(/(<i>|<\/i>)/,'')
    end

    def image_set_path_from_work(work)
        cache_key = "ispfw-work-#{work.id}-#{work.updated_at.try(:utc).try(:to_s, :number)}"
        Rails.cache.fetch(cache_key) do
            image_set = work.edition.image_set.leaves_showing_work(work).first
            edition_image_set_path(work.edition, image_set) if image_set
        end
    end

    def image_set_url_from_work(work)
        cache_key = "isufw-work-#{work.id}-#{work.updated_at.try(:utc).try(:to_s, :number)}"
        Rails.cache.fetch(cache_key) do
            image_set = work.edition.image_set.leaves.where(
              nestable_type: 'Image',
              nestable_id: work.image_set.all_images.first.id
            ).first
            edition_image_set_url(work.edition, image_set) if image_set
        end
    end

    def edition_selector_by_image(image, selected_edition, id = nil)
        options = []
        disabled = []
        selected = selected_edition.id
        Edition.for_user(current_user).each do |edition|
            link = edition.id
            next if edition.image_set.nil?
            images_in_this_edition = edition.image_set.leaves_containing(image)
            if edition.works.in_image(image).empty? || images_in_this_edition.first.nil?
                disabled << link unless link == selected_edition.id
            else
                link = edition_image_set_path(edition, images_in_this_edition.first)
                selected = link if edition == selected_edition
            end
            options << [edition.short_name, link]
        end
        options = options.sort_by{|o| o[1] == selected ? 1 : 2}

        select_tag 'edition[id]', options_for_select(options, disabled: disabled, selected: selected), class: 'edition-selector', id: id
    end

    def edition_selector(other_editions_works, selected_edition, id = nil)
        other_editions_works ||= []
        options = []
        disabled = []
        selected = selected_edition.id
        other_editions = Hash[other_editions_works.map{|w| [w.edition.id, w.id]}]
        Edition.for_user(current_user).each do |edition|
            link = edition.id
            if other_editions[edition.id]
                link = image_set_path_from_work(Work.find(other_editions[edition.id]))
            else
                disabled << link unless link == selected_edition.id
            end
            options << [edition.short_name, link]
        end
        options = options.sort_by{|o| o[1] == selected ? 1 : 2}

        select_tag 'edition[id]', options_for_select(options, disabled: disabled, selected: selected), class: 'edition-selector', id: id
    end

    def cache_key_for_works(works, edition=nil)
        count          = works.count
        max_updated_at = works.maximum(:updated_at).try(:utc).try(:to_s, :number)
        edition_id = edition ? "-with_edition-#{edition.id}" : ''
        "works/many-#{count}-#{max_updated_at}#{edition_id}"
    end

    def search_rank(search, work)
        search.hits.index{|h| h.primary_key == work.id.to_s && h.class_name == work.class.name} + 1
    end

    def with_format(format, &block)
        old_formats = formats
        begin
            self.formats = [format]
            return block.call
        ensure
            self.formats = old_formats
        end
    end
end
