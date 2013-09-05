#!/bin/env ruby
# encoding: utf-8

class CharMap
    CHARMAP = {
        /(^|\b|\s|\w)&(\b|\s|$|\W)/ => '\1&amp;\2',
        '<137>' => '&euml;',
        '<138>' => '&egrave;',
        '<161>' => '&iacute;',
        '<166>' => 'fi',
        '<167>' => 'fl',
        #'<169>' => '“',
        #'<170>' => '”',
        '<169>' => '&quot;',
        '<170>' => '&quot;',
        '<195>' => '&#8226;',
        '<196>' => '&ndash;',
        '<197>' => '&mdash;',
        /<(F58586)?MI>/  => '<em>',
        /<(F58586)?MU>/ => '<u>', # underlined for real
        '<F53621>' => '<b>', # Small caps
        '<_><|>' => '  ',
        '<_>' => ' ',
        '<N>' => ' ',
        /<F38376(M|MI)?>u/ => ' &#124;',
        /<F38376(k|MI)?>i/ => ' &#124;&#124;',
        '<R>' => '<br/>',
        "\r" => ''
    }

    CHARMAP_NOITALS = {
        '<137>' => 'ë',
        '<138>' => 'è',
        '<161>' => 'í',
        '<166>' => 'fi',
        '<167>' => 'fl',
        #'<169>' => '“',
        #'<170>' => '”',
        '<169>' => '"',
        '<170>' => '"',
        '<195>' => '•',
        '<196>' => '–',
        '<197>' => '—',
        '<MI>'  => '',
        '<MU>' => '',
        '<D>'   => '',
        '<_><|>' => '  ',
        '<_>' => ' ',
        '<R>' => ''
    }

    def self.replace(text)
        CHARMAP.each do |k, v|
            text.gsub!(k, v) if text
        end
        text
    end

    def self.replace_no_itals(text)
        CHARMAP_NOITALS.each do |k, v|
            text.gsub!(k, v) if text
        end
        text
    end
end
