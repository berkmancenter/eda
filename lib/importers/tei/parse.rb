class TEIImporter
    def import(edition, number, variant, filename)
        doc = Nokogiri::XML(File.read(filename))
        w = Work.find_by_number_and_variant(number, variant)
        w.destroy
        w = Work.new(:title => doc.css('title').text, :number => number, :variant => variant)
        line_index = 0
        doc.css('lg[type=stanza]').each_with_index do |stanza, i|
            s = Stanza.new(:position => i)
            stanza.css('l').each do |line|
                line_index += 1
                orphans = {}
                if line['n']
                    line_num = line['n'] = line_index
                else
                    line_num = line_index
                end
                line.traverse do |child|

                    next unless child.class == Nokogiri::XML::Element

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
                            :new_characters => clean_str(child),
                        )
                    elsif child.matches? 'del[@type="canceled"]'
                        m = Alternate.new(
                            :subtype => 'cancellation',
                            :original_characters => clean_str(child),
                        )
                    elsif child.matches? 'supplied'
                        m = Emendation.new(
                            :new_characters => clean_str(child),
                        )
                    end

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
                    w.line_modifiers << m
                end
                s.lines << Line.new(
                    :number => line_num,
                    :text => clean_str(line)
                )
            end
            w.stanzas << s
        end
        edition.works << w
        edition.save!
    end

    private

    def clean_str(parent_node, node_to_keep = nil)
        mine = Nokogiri.XML('<doc xmlns="http://www.tei-c.org/ns/1.0"><mine></mine></doc>').at_css('mine')
        parent_node.traverse do |c|
            mine << c.clone if c == node_to_keep || (['text'].include?(c.name) && c.parent == parent_node)
        end
        mine.inner_html
    end

    def start_address(line_node, node_to_find)
        clean_str(line_node, node_to_find).index(node_to_find.to_html)
    end
end
