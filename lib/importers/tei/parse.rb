class TEIImporter
    def import(edition, filename)
        doc = Nokogiri::XML(File.read(filename))
        w = Work.new(
            :title => doc.css('title').text
        )
        line_index = 1
        doc.css('lg[type=stanza]').each do |stanza|
            s = Stanza.new(:position => w.stanzas.count)
            stanza.css('l').each do |line|
                line_index += 1
                if line['n']
                    line_num = line['n'] = line_index
                else
                    line_num = line_index
                end
                line.element_children.each do |child|
                    if child.matches? 'app[@type="emendation"]'
                        mine = clean_str(line, child)
                        m = Emendation.new(
                            :original_characters => child.css('lem').text,
                            :new_characters => child.css('rdg').text,
                        )
                    elsif child.matches? 'app[@type="division"]'
                        subtype = 'line'
                        subtype = 'author' unless child.css('lb[rend="none"]').empty?
                        subtype = 'page_or_column' unless child.css('pb').empty?
                        m = Division.new(
                            :subtype => subtype,
                        )
                    elsif child.matches? 'add'
                        subtype = child['type'] || 'alternate'
                        m = Alternate.new(
                            :subtype => subtype,
                            :original_characters => child['extent'],
                            :new_characters => child.text,
                        )
                    elsif child.matches? 'del[@type="canceled"]'
                        mine = clean_str(line, child)
                        m = Alternate.new(
                            :subtype => 'cancellation',
                            :original_characters => child.text,
                        )
                    elsif child.matches? 'supplied'
                        mine = clean_str(line, child)
                        m = Emendation.new(
                            :new_characters => child.text,
                        )
                    end
                    if m 
                        m.assign_attributes(
                            :start_address => start_address(line, child),
                            :start_line_number => line_num,
                            :end_line_number => line_num
                        )
                        w.line_modifiers << m
                    end
                end
                s.lines << Line.new(
                    :number => line_num,
                    :text => clean_str(line)
                )
            end
            w.stanzas << s
        end
        w.save!
        edition.works << w
        edition.save!
    end

    private

    def clean_str(line_node, node_to_keep = nil)
        mine = Nokogiri.XML('<doc xmlns="http://www.tei-c.org/ns/1.0"><mine></mine></doc>').at_css('mine')
        line_node.traverse{|c| mine << c.clone if c == node_to_keep || (['text'].include?(c.name) && c.parent == line_node)}
        mine.inner_html
    end

    def start_address(line_node, node_to_find)
        clean_str(line_node, node_to_find).index(node_to_find.to_html)
    end
end
