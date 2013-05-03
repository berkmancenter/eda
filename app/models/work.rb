class Work < ActiveRecord::Base
    belongs_to :edition
    belongs_to :image_group
    has_many :stanzas, :order => 'position'
    has_many :lines, :through => :stanzas, :order => 'number'
    has_many :line_modifiers
    has_many :divisions
    has_many :emendations
    has_many :alternates
    has_many :revisions
    has_many :appearances, :class_name => 'WorkAppearance'
    attr_accessible :date, :metadata, :number, :title, :variant

    def line(number)
        lines.find_by_number(number)
    end

    #def number
    #    "#{edition.work_number_prefix}#{read_attribute(:number)}"
    #end
        
    def apps_at_address(line, char_index)
        (divisions + emendations + revisions + alternates).select do |apparatus|
            apparatus.line_num == line && apparatus.start_address == char_index
        end
    end

    def holder_code=(code)
    end

    def holder_subcode=(subcode)
    end

    def holder_id=(id)
    end

    def fascicle=(id)
    end

    def fascicle_position=(id)
    end
end
