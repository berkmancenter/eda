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

    def work_link(work, edition)
      page_with_work = work.edition.image_set.with_work(work)

        link_to(
            raw(
                work.title ?
                work.full_title :
                (work.lines.first.text if work.lines.first)
        ),
            edition_image_set_path(edition, page_with_work)
        ) if page_with_work
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
