# == Schema Information
#
# Table name: works
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  date                      :datetime
#  number                    :integer
#  variant                   :string(255)
#  metadata                  :text
#  edition_id                :integer
#  image_set_id              :integer
#  cross_edition_work_set_id :integer
#  revises_work_id           :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class Work < ActiveRecord::Base
    belongs_to :edition
    belongs_to :revises_work, class_name: 'Work'
    belongs_to :image_set

    has_many :sets, as: :nestable, class_name: 'WorkSet'
    has_many :stanzas, order: :position
    has_many :lines, through: :stanzas, order: :number
    has_many :line_modifiers
    has_many :divisions
    has_many :emendations
    has_many :alternates
    has_many :revisions
    has_many :appearances, class_name: 'WorkAppearance'

    attr_accessible :date, :metadata, :number, :title, :variant, :text
    after_initialize :setup_defaults
    before_create :setup_work
    default_scope order(:number, :variant)
    scope :starts_with, lambda { |first_letter| where('title ILIKE ?', "#{first_letter}%") }

    serialize :metadata

    searchable do
        integer :edition_id
        string(:number) { |work| work.number.to_s }
        text :title
        text :lines do
            lines.map{|l| l.text }
        end
    end

    def line(number)
        lines.find_by_number(number)
    end

    def full_title
        "#{edition.work_number_prefix}#{number}#{variant} - #{title}"
    end
    
    def next
        edition.works.where{
            (number > my{number}) | ((number == my{number}) & (variant > my{variant}))
        }.order(:number, :variant).first
    end

    def previous
        edition.works.where{
            (number < my{number}) | ((number == my{number}) & (variant < my{variant}))
        }.order(:number, :variant).last
    end

    def variants
        edition.works.where{(number == my{number}) & (variant != my{variant})}
    end
        
    def apps_at_address(line, char_index)
        (divisions + emendations + revisions + alternates).select do |apparatus|
            apparatus.line_num == line && apparatus.start_address == char_index
        end
    end

    def holder_code=(code)
        self.metadata['holder_code'] = code
    end

    def holder_subcode=(subcode)
        self.metadata['holder_subcode'] = subcode
    end

    def holder_id=(id)
        self.metadata['holder_id'] = id
    end

    def fascicle=(fascicle)
        self.metadata['fascicle'] = fascicle
    end

    def fascicle_position=(position)
        self.metadata['fascicle_position'] = position
    end

    def has_image?
        image_set.all_images.any?{|i| i.url && !i.url.empty?}
    end

    def self.in_image(image)
        all.select{|w| w.image_set.all_images.include? image}
    end


    def text=(text)
        line_modifiers.delete_all
        stanza = Stanza.new(position: 0)
        new_stanzas = []
        page_break_pattern = /^((\*\s*){3,}|(-\s*){3,}|(_\s*){3,})$/
        stanza_break_pattern = /^\s*$/
        line_number = 0
        text.lines.each_with_index do |line, i|
            if line.match(page_break_pattern)
                address = text.lines.to_a[i - 1].length - 2
                self.divisions << Division.new(
                    start_line_number: line_number,
                    end_line_number: line_number,
                    start_address: address,
                    end_address: address, 
                    subtype: 'page_or_column',
                )
            elsif line.match(stanza_break_pattern)
                new_stanzas << stanza
                stanza = Stanza.new(position: new_stanzas.count)
            else
                line_number += 1
                stanza.lines.new(number: line_number, text: line.strip)
            end
        end
        new_stanzas << stanza
        self.stanzas = new_stanzas
    end

    private
    
    def setup_defaults
        self.metadata ||= {}
    end

    def setup_work
        self.image_set = ImageSet.create
    end
end
