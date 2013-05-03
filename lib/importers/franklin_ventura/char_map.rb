#!/bin/env ruby
# encoding: utf-8

class CharMap
    CHARMAP = {
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
        '<MI>'  => '<i>',
        '<D>'   => '</i>',
        '<_><|>' => '  ',
        '<_>' => ' ',
        '<R>' => ''
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
