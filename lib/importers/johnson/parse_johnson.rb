class JohnsonImporter
    def import(filename)
        text = File.readlines(filename)
        text.delete_if { |line| line.match /^\s*\[\s*\d*\s*\]\s*$/ }
        in_manuscript_block = false
        number_pattern = /^\s*\d+\s*$/ 
            text.map! do |line|
            output = nil
            if line.match(/Manuscript/) || line.match(/^\s*(Manuscripts?|Publication):/) || line.match(/^ {5}\w/) || line.match(/^\s*\d+((-|, )\d+)?(\.|\])/) || (line.length >= 70 && line.index('[no stanza').nil? && line.index('version of 18').nil?) || line.match(/No autograph/) || line.match(/This.*poem/) || line.match(/These lines/) || line.match(/4 \[If/)
                in_manuscript_block = true
            end

            unless in_manuscript_block
                output = line.rstrip + "\n"
            end

            if line.match(number_pattern) && in_manuscript_block
                in_manuscript_block = false
            end

            if line.match(number_pattern)
                output = "[poem end]\n\n#{line.strip}\n[poem start]\n"
            end
            output
            end
        poems = text.compact!.join.gsub("\n\n\n", "\n\n").gsub(/\n*\s*\[no stanza break\]\s*\n*/, "\n")
        File.write('JohnsonEdition2.txt', poems)
    end
end
