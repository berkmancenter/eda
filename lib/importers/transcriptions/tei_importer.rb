class TEIImporter
    def import_from_file(filename)
        string = File.read(filename)
        import!(string)
    end

    def get_work(edition_prefix, number, variant)
       works = Work.joins(:edition)
       works = works.where(number: number) if number
       works = works.where(variant: variant) if variant
       works = works.where(edition: { work_number_prefix: edition_prefix }) if edition_prefix
       works.first
    end

    def parse_line(line, line_index = nil)
        orphans = {}
        line_modifiers = []
        if line['n']
            line_num = line['n']
        else
            line_num = line_index
        end
        if line_num.nil?
            puts 'Need line number:'
            puts line
            exit
        end
        line.traverse do |child|
            next unless child.class == Nokogiri::XML::Element
            m = create_modifier_from_node(child)
            next unless m
            m.start_address = start_address(child.parent, child)
            if child.parent == line
                m.assign_attributes(
                    :start_line_number => line_num,
                    :end_line_number => line_num
                )
            else
                if orphans[child.parent]
                    orphans[child.parent] << m
                else
                    orphans[child.parent] = [m]
                end
            end
            if orphans[child]
                m.children = orphans[child]
                orphans[child] = nil
            end
            line_modifiers << m
        end
        {
            line: Line.new( :number => line_num, :text => clean_str(line)),
            modifiers: line_modifiers
        }

    end

    def import(string, work = nil)
        doc = Nokogiri::XML(string)
        unless work
            edition_prefix, work_number, work_variant = parse_id(doc.at('body > div[type=transcript]')['id'])
            work = get_work(edition_prefix, work_number, work_variant)
        end
        work.title = doc.css('title').text
        work.number = work_number
        work.variant = work_variant
        work.stanzas.destroy_all
        line_index = 0
        doc.css('lg[type=stanza]').each_with_index do |stanza, i|
            s = Stanza.new(:position => i)
            stanza.css('l').each do |line|
                line_index += 1
                line_object, modifiers = parse_line(line, line_index).values
                line_index = line_object.line_num
                s.lines << line_object
            end
            work.stanzas << s
        end
        work
    end

    def import!(string)
        work = import(string)
        work.save!
    end

    private

    def clean_str(parent_node, node_to_keep = nil)
        mine = Nokogiri.XML('<doc xmlns="http://www.tei-c.org/ns/1.0"><mine></mine></doc>').at_css('mine')
        parent_node.traverse do |c|
            mine << c.clone if c == node_to_keep || (['text', 'emph'].include?(c.name) && c.parent == parent_node)
        end
        mine.inner_html.gsub('emph>', 'em>')
    end

    def create_modifier_from_node(node)
        if node.matches? 'app[@type="emendation"]'
            m = Emendation.new(
                :original_characters => node.css('lem').text,
                :new_characters => node.css('rdg').text,
            )
        elsif node.matches? 'app[@type="division"]'
            subtype = 'line'
            subtype = 'author' unless node.css('lb[rend="none"]').empty?
            subtype = 'page_or_column' unless node.css('pb').empty?
            m = Division.new(
                :subtype => subtype,
            )
        elsif node.matches? 'add'
            subtype = node['type'] || 'alternate'
            m = Alternate.new(
                :subtype => subtype,
                :original_characters => node['extent'],
                :new_characters => clean_str(node),
            )
        elsif node.matches? 'del[@type="canceled"]'
            m = Alternate.new(
                :subtype => 'cancellation',
                :original_characters => clean_str(node),
            )
        elsif node.matches? 'supplied'
            m = Emendation.new(
                :new_characters => clean_str(node),
            )
        end
        m
    end

    def start_address(line_node, node_to_find)
        clean_str(line_node, node_to_find).index(node_to_find.to_html)
    end
end
