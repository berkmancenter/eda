class Word < ActiveRecord::Base
  attr_accessible :endings, :part_of_speech, :word
  has_many :definitions, :order => 'number'
end
