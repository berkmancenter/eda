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
        output = ''
        line.chars.each_with_index do |char, i|
            line.mods_at(i).each do |mod|
                output += render_mod(mod)
            end
            output += char
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
        image_set = work.edition.image_set.leaves_showing_work(work).first
        edition_image_set_path(work.edition, image_set) if image_set
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
