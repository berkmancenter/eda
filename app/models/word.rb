# == Schema Information
#
# Table name: words
#
#  id            :integer          not null, primary key
#  word          :string(255)
#  sortable_word :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Word < ApplicationRecord
    default_scope { order(:sortable_word) }
    has_many :variants, class_name: 'WordVariant'
    scope :starts_with, lambda { |first_letter| where('word ILIKE ?', "#{first_letter}%") }

    searchable do
        text :word
    end
end
