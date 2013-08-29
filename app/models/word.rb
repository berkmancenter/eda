# == Schema Information
#
# Table name: words
#
#  id             :integer          not null, primary key
#  word           :string(255)
#  endings        :string(255)
#  part_of_speech :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Word < ActiveRecord::Base
    attr_accessible :endings, :part_of_speech, :word
    has_many :definitions, :order => 'number'
    default_scope order(:word)
    scope :starts_with, lambda { |first_letter| where('word ILIKE ?', "#{first_letter}%") }

    searchable do
        text :word
    end
end
