class Line < ActiveRecord::Base
  belongs_to :stanza
  attr_accessible :number, :text
end
