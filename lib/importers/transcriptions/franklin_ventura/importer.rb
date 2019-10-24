# This has a lot to do:
# Create Franklin edition
# Create the works, lines, stanzas, and line modifiers
# Set numbers?
# Variant collections

require_relative 'field_parsing.rb'
require_relative 'char_map.rb'
require_relative 'patterns.rb'

include FieldParsing
include Patterns

class MatchData
    def named_captures
        Hash[ self.names.zip( self.captures ) ]
    end
end

module FranklinVentura
    class Importer
        include ActionView::Helpers::SanitizeHelper
        def create_edition
            edition = Edition.new(
                name: 'The Poems of Emily Dickinson, Variorum Edition, Franklin, 1998',
                short_name: 'Franklin Variorum 1998',
                citation: 'The Poems of Emily Dickinson, Variorum Edition, Edited by R. W. Franklin, Cambridge, Mass.: Belknap Press of Harvard University Press, 1998',
                author: 'R. W. Franklin',
                date: Date.new(1998, 1, 1),
                work_number_prefix: 'F',
                completeness: 1.0,
                :public => true
            )
            edition.create_image_set(
                name: "Images for #{edition.name}",
                editable: true
            )
            edition.create_work_set(
                name: "Works in #{edition.name}",
                editable: true
            )
            edition
        end

        def markup_file(file, simple = false)
            string = file.read
            string.gsub!(Full_title_extractor, "\n</work>\n\n<work>\n<number>\\k<number></number>\n<title>\\k<title></title>\n")
            string.gsub!(Variant_title_extractor, "\n<title>\\k<title></title>\n")
            string.gsub!(Poem_start_pattern, "\n<poem>\n\\1")
            string.gsub!(Poem_end_pattern, "\n</stanza>\n</poem>\n\n\\1")
            string.gsub!(Published_extractor, "<published><publication>\\k<publication></publication><date>\\k<year>-\\k<month>-\\k<day></date><pages>\\k<pages></pages><variant>\\k<source_variant></variant></published>") unless simple
            string.gsub!(Publication_extractor, "\n<publications>\\k<publications></publications>\n")
            string.gsub!(Manuscript_extractor, "\n<manuscript>\\k<manuscript></manuscript>\n")
            # Twice on purpose for when patterns overlap
            string.gsub!(Holder_extractor, "\\k<before><holder><loccode>\\k<loc_code></loccode><subloccode>\\k<subloc_code></subloccode><id>\\k<id></id></holder>\\k<after>") unless simple
            string.gsub!(Holder_extractor, "\\k<before><holder><loccode>\\k<loc_code></loccode><subloccode>\\k<subloc_code></subloccode><id>\\k<id></id></holder>\\k<after>") unless simple

            if simple
                string.gsub!(Revision_extractor, "\n<mods><MI>Revision<D> \\k<revisions></mods>\n")
                string.gsub!(Alternate_extractor, "\n<mods>\\k<alternates></mods>\n")
                string.gsub!(Emendation_extractor, "\n<mods><MI>Emendation<D> \\k<emendations></mods>\n")
                string.gsub!(Division_extractor, "\n<mods><MI>Division<D> \\k<divisions></mods>\n")
            else
                string.gsub!(Revision_extractor, "\n<revisions>\\k<revisions></revisions>\n")
                string.gsub!(Alternate_extractor, "\n<alternates>\\k<alternates></alternates>\n")
                string.gsub!(Emendation_extractor, "\n<emendations>\\k<emendations></emendations>\n")
                string.gsub!(Division_extractor, "\n<divisions>\\k<divisions></divisions>\n")
            end

            string.gsub!(Stanza_start_pattern, "\n<stanza>\n\\0")
            string.gsub!(Stanza_boundary_pattern, "</stanza>\n<stanza>\n\\0")
            string.gsub!(Paragraph_extractor, "\n<p>\\k<paragraph></p>\n")
            string.gsub!(Publication_deviation_extrator, "\n<deviations>\n<variant>\\k<variant></variant>\\k<deviations>\n</deviations>\n")
            string.gsub!(Year_extractor, "\n<year>\\k<year></year>\n")
            string = markup_poem_lines(string)
            string = fix_poem_closures(string)
            string = CharMap.replace(string)
            string = fix_font_changes(string)
            string.gsub!('<<', '&laquo;')
            string.gsub!('>>', '&raquo;')
            string.gsub!('<~>', '<br/>')
            string = sanitize(string, tags: %w(br em b u p holder loccode subloccode id deviations fascicle line variant linenum year work title poem stanza mods publications published publication date pages manuscript number alternates emendations divisions revisions))
            string.sub!('</work>', '')
            string << "\n</work>\n"
            string.gsub!(/^(@|@1 = |@6.5PTS = |@PGBRK = |@PNT_1_1 = |@TRH1 = .*)$/, '')
            string.gsub!(/^\s*$\n/, '')
            string = split_variants(string)
            string = stick_modifiers_in_poems(string)
            string
        end

        def stick_modifiers_in_poems(string)
            new_string = ''
            have_poem_end = false
            hold_pattern = /^(<divisions|<emendations|<revisions|<alternates|<mods)/
            poem_end_pattern = /<\/poem>/
            string.each_line do |line|
                if line.match(poem_end_pattern)
                    have_poem_end = true
                elsif !line.match(hold_pattern) && have_poem_end
                    new_string << "</poem>\n#{line}"
                    have_poem_end = false
                else
                    new_string << line
                end
            end
            new_string
        end

        def markup_poem_lines(string)
            new_string = ''
            string.each_line do |line|
                new_line = ''
                Poem_line_extractors.each do |pattern|
                    if match = line.match(pattern)
                        hash = Hash[match.names.zip(match.captures)]
                        hash.each do |name, match|
                            new_line << "<#{name}>#{match}</#{name}>"
                        end
                        break
                    end
                end
                new_line.sub!(/<\/line><line_num>(.*)<\/line_num>/, '<linenum>\1</linenum></line>')
                if new_line.empty?
                    new_string << line
                else
                    new_string << new_line + "\n"
                end
            end
            new_string
        end

        def previous_open_tag(offset, line)
            tags = ['em', 'u', 'b']
            pattern = '('
            tags.each do |tag|
                open_tag = "<#{tag}>".reverse
                close_tag = "</#{tag}>".reverse
                pattern << "#{open_tag}|#{close_tag}|"
            end
            pattern << "#{Normal_font_reversed.to_s})"
            if match = line.reverse.match(pattern, line.length - offset - 1)
                tag = match[0].reverse
                return tag if tag.match('<[a-z]+>')
            end
        end

        def fix_font_changes(string)
            new_string = ''
            string.each_line do |line, i|
                closings = line.scan(Normal_font).map(&:first)
                closings.each do |closing|
                    match = line.match(closing)
                    replacement = previous_open_tag(match.offset(0)[0], line) || ''
                    line.sub!(closing, replacement.sub('<', '</'))
                end
                new_string << line
            end
            new_string
        end

        def fix_poem_closures(string)
            in_poem = false
            new_string = ""
            string.each_line do |line|
                unless in_poem == false && (line.match(/<\/stanza>/) || line.match(/<\/poem>/) || line.match(/<stanza>/))
                    new_string << line
                end
                in_poem = true if line.match(/<poem>/)
                in_poem = false if line.match(/<\/poem>/)
            end
            new_string
        end

        def import(directory, from_year = 1850, to_year = 1886)
            puts "Importing Franklin works"
            edition = create_edition
            @poems = []
            simple_string = ''
            complex_string = ''

            Dir.open(directory).sort.each do |filename|
                next unless File.extname(filename) == '.TXT' && ((from_year..to_year).include?(filename.to_i) || filename == 'UNDATED.TXT')
                simple_string << markup_file(File.open("#{directory}/#{filename}"), true)
                complex_string << markup_file(File.open("#{directory}/#{filename}"))
            end
            simple_string = "<works>#{simple_string}</works>"
            complex_string = "<works>#{complex_string}</works>"

            File.write(Rails.root.join('tmp', 'franklin_test_complex.xml'), complex_string)
            File.write(Rails.root.join('tmp', 'franklin_test_simple.xml'), simple_string)
            works = parse_xml(simple_string, complex_string)
            edition.works = works
            edition.save!
            post_process!(edition)
        end

        # For poems like 1356
        def split_variants(string)
            string.gsub(/<variant>([^<]+), ([^<]+)<\/variant>/, '<variant>\1</variant><variant>\2</variant>')
        end

        def breakup_publications(work)
            work.metadata['Publications'] = work.metadata['Publication'].split(/(\.|;)/).selecting{|s| !['.',';'].include?(s)}
        end

        def parse_xml(simple_string, complex_string)
            works = []
            doc = Nokogiri::XML::Document.parse(complex_string.encode('ASCII-8BIT'), nil, nil, Nokogiri::XML::ParseOptions::RECOVER)
            simple_doc = Nokogiri::XML::Document.parse(simple_string.encode('ASCII-8BIT'), nil, nil, Nokogiri::XML::ParseOptions::RECOVER)
            pbar = ProgressBar.new('Parsing Franklin', doc.css('work').count)
            doc.css('work').each_with_index do |work, i|
                simple_work = simple_doc.css('work')[i]
                year = work.xpath('preceding-sibling::year').last.text.to_i
                number = work.at('number').text.to_i
                #puts number
                titles = work.css('title').map(&:text)
                work.css('poem').each_with_index do |poem, i|
                    poem.css('variant').each do |variant|
                        variant = variant.inner_html
                        next unless variant
                        secondary = false
                        if secondary = variant.match(Secondary_source_pattern)
                            variant = secondary[:variant]
                        end
                        w = Work.create(
                            number: number,
                            title: titles[i] || titles.first,
                            variant: variant,
                            secondary_source: !!secondary
                        )
                        w.date = Date.new(year, 1, 1) if year > 0

                        add_stanzas(w, poem)
                        add_manuscript(w, work, simple_work)
                        add_holder_info(w, poem)
                        add_publication(w, work, simple_work)
                        add_fascicle_set_info(w, poem)
                        add_mods(w, work, simple_work)
                        breakup_publications(w)
                        w.save!
                        add_modifiers!(w, poem)
                        works << w
                    end
                    pbar.inc
                end
            end
            works
        end

        def add_mods(work, poem_xml, simple_xml)
            work.metadata['Inscription Notes'] = simple_xml.css('mods').map{|m| m.inner_html}.join("<br />")
        end

        def add_fascicle_set_info(work, poem_xml)
            return unless poem_xml.at('fascicle')
            pattern = /<b>(?<type>f|s)<\/b>(?<number>[0-9.]+)/
            matches = poem_xml.at('fascicle').inner_html.match(pattern)
            return unless matches && matches[:type] && matches[:number]
            case matches[:type]
            when 'f'
                numbers = matches[:number].split('.').map(&:to_i)
                work.metadata['fascicle'] = numbers.first
                work.metadata['fascicle_order'] = numbers.last
            when 's'
                work.metadata['set'] = matches[:number].to_i
            end
        end

        def add_holder_info(work, poem_xml)
            if work.variant == 'A'
                previous_sibling = poem_xml.parent.at('manuscript')
            else
                previous_sibling = poem_xml.previous_element if poem_xml.previous_element.matches?('p')
            end
            if previous_sibling
                work.metadata['Note'] = previous_sibling.text
                if previous_sibling.css('holder').count > 0
                    work.clear_holder_info
                    # Work gets last holder in paragraph
                    previous_sibling.css('holder').each do |holder|
                        holder_ids = holder.at('id').text.strip.split(/(^\d+\/|,)/).reject{|i| i.to_i == 0}.map{|id| id.strip.sub(/\/$/, '')}
                        holder_ids.each do |id|
                            work.holder_code = holder.at('loccode').text.strip
                            work.holder_subcode = holder.at('subloccode').text.strip
                            work.holder_id = id
                        end
                    end
                end
            end
        end

        def add_publication(work, work_xml, simple_work_xml)
            if node = simple_work_xml.at('publications')
                work.metadata['Publication'] = node.inner_html
            end
            if node = work_xml.at('publications')
                node.css('published').each do |published|
                    if variant = published.at('variant')
                        next unless work.variant == variant.text.strip || variant.text.empty?
                    end
                    year, month, day = published.at('date').text.split('-').compact
                    month ||= 1
                    day ||= 1
                    work.appearances.create(
                        publication: published.at('publication').inner_html,
                        date: Date.parse("#{year}-#{month}-#{day}"),
                        pages: published.at('pages').text
                    )
                end
            end
        end

        def add_manuscript(work, work_xml, simple_work_xml)
            if node = simple_work_xml.at('manuscript')
                work.metadata['Manuscript'] = node.inner_html
            end
        end

        def add_stanzas(work, poem_xml)
            poem_xml.css('stanza').each_with_index do |stanza, i|
                s = work.stanzas.build(position: i)
                stanza.css('line').each do |line|
                    if line.at('linenum')
                        line_number = line.at('linenum').text.to_i
                        line.at('linenum').remove
                    else
                        line_number = line_number(work, s, {'line_num' => ''})
                    end
                    s.lines.build(
                        text: line.inner_html.gsub('"', '&quot;'),
                        number: line_number
                    )
                end
            end
            work
        end

        def add_modifiers!(poem, poem_xml)
            ['division', 'emendation', 'revision', 'alternate'].each do |var|
                capped = var.camelize
                next unless node = poem_xml.at(var.pluralize)
                inner_xml = node.inner_html 
                instances = prep_modifier(inner_xml)
                instances.each do |instance|
                    i = self.send("get_#{var}", instance)
                    poem.line_modifiers.push(*i) if i 
                end
            end
        end

        def line_number(poem, stanza, matches)
            line_num = nil
            # First line of work
            if stanza.lines.empty? && (poem.stanzas.empty? || poem.stanzas.size == 1)
                line_num = 1
            # Next line in current stanza 
            elsif stanza.lines.last && stanza.lines.last.number
                line_num = stanza.lines.last.number + 1
            # Next line in new stanza
            elsif stanza.position > 0 && poem.stanzas[-2].lines.last.number
                line_num = poem.stanzas[-2].lines.last.number + 1
            else
                puts poem.stanzas.inspect
                puts stanza.lines.inspect
                puts matches.inspect
                exit
            end
            if matches['line_num'].to_i > 0
                line_num = matches['line_num'].to_i
            end
            line_num
        end

        def post_process!(edition)
            locate_emendations!(edition)
            locate_divisions!(edition)
            locate_alternates!(edition)
        end

        def prep_modifier(inner_xml)
            mods = inner_xml.split(/<br\s?\/?>/).drop(1).map(&:strip).delete_if do |d|
                if d.include?('<em>') 
                    #puts "mod: #{d}"
                    true
                else
                    false 
                end
            end
        end


        def pattern(chars)
            Regexp.new("(^|\\b|\\s)#{Regexp.escape(chars)}($|\\b|\\s)")
        end

        def locate_emendations!(edition)
            pbar = ProgressBar.new("Locating Emendations", edition.works.reduce(0){|c, w| w.emendations.count + c})
            edition.works.each do |work|
                work.emendations.each do |e|
                    pbar.inc
                    next unless e.start_address == nil && e.new_characters
                    pattern = pattern(e.new_characters)
                    line = work.line(e.start_line_number)
                    mods = line.line_modifiers if line
                    if mods && mods.count > 1
                        mods.each do |mod|
                            if mod.original_characters.nil?
                                puts mod.inspect
                            end
                        end
                        mods.sort_by!{|mod| sanitize(line.text).index(pattern(mod.original_characters)) || 0 }.reverse!
                        mods.each do |mod|
                            pull_emendation(line, mod)
                        end
                    else
                        pull_emendation(line, e)
                    end
                end
            end
        end

        def pull_emendation(line, e)
            return unless line && e.new_characters && match = sanitize(line.text).match(pattern(e.new_characters))
            e.start_address = match.offset(0)[0]
            e.start_address += 1 if match[0][0] == ' '
            e.end_address = e.start_address + e.new_characters.length if e.start_address
            e.save!
            # TODO: This isn't going to pull out the emendation correctly if
            # the emendation contains tags
            line.text = line.text.sub(e.new_characters, '')
            line.save!
        end

        def locate_divisions!(edition)
            pbar = ProgressBar.new("Locating Divisions", edition.works.reduce(0){|c, w| w.divisions.count + c})
            edition.works.each do |work|
                work.divisions.each do |e|
                    if e.parent
                        line = sanitize(e.parent.chars.join)
                    elsif work.line(e.start_line_number)
                        line = sanitize(work.line(e.start_line_number).text)
                    end
                    if line && line.index(pattern(e.original_characters))
                        e.start_address = line.index(pattern(e.original_characters)) + e.original_characters.length + 1
                        e.end_address = e.start_address if e.start_address
                        e.save!
                    end
                    pbar.inc
                end
            end
        end

        def locate_alternates!(edition)
            pbar = ProgressBar.new("Locating Alternates", edition.works.reduce(0){|c, w| w.alternates.count + c})
            edition.works.each do |work|
                work.alternates.each do |e|
                    line = work.line(e.start_line_number)
                    if line && e.start_address == 0 && e.end_address == 9999
                        e.end_address = line.text.length - 1
                        e.save!
                    elsif line && sanitize(line.text).index(pattern(e.original_characters))
                        e.start_address = sanitize(line.text).index(pattern(e.original_characters))
                        e.end_address = e.start_address if e.start_address
                        e.save!
                    end
                    pbar.inc
                end
            end
        end
    end
end
