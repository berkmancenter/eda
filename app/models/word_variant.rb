class WordVariant < ActiveRecord::Base
    attr_accessible :endings, :part_of_speech, :word, :etymology
    belongs_to :word
    has_many :definitions, :order => 'number'
end
