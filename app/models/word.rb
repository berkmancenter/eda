class Word < ActiveRecord::Base
    attr_accessible :endings, :part_of_speech, :word
    has_many :definitions, :order => 'number'
    default_scope order(:word)
    scope :starts_with, lambda { |first_letter| where('word ILIKE ?', "#{first_letter}%") }

    searchable do
        text :word
    end
end
