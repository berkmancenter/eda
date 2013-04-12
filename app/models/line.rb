class Line < ActiveRecord::Base
  belongs_to :stanza
  has_one :work, :through => :stanza
  has_many :line_modifiers, :through => :work, :conditions => proc{ "start_line_number <= #{number} AND end_line_number >= #{number}" }
  attr_accessible :number, :text
end
