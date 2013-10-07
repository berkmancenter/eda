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
    default_scope order(:sortable_word)
    has_many :variants, class_name: 'WordVariant'
    scope :starts_with, lambda { |first_letter| where('word ILIKE ?', "#{first_letter}%") }

    searchable do
        text :word
    end
end
