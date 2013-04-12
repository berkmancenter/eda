class LineModifier < ActiveRecord::Base
  belongs_to :start_line
  attr_accessible :start_line_number, :end_address, :end_line_number, :new_characters, :original_characters, :start_address, :subtype, :type
end
