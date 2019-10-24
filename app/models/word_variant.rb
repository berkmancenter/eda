# == Schema Information
#
# Table name: word_variants
#
#  id             :integer          not null, primary key
#  word_id        :integer
#  endings        :string(255)
#  part_of_speech :string(255)
#  etymology      :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class WordVariant < ApplicationRecord
    attr_accessible :endings, :part_of_speech, :word, :etymology
    belongs_to :word, optional: true
    has_many :definitions, -> { order('number') }
end
