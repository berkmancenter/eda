class Definition < ActiveRecord::Base
  belongs_to :word
  attr_accessible :definition, :number
end
