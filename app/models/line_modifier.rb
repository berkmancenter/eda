class LineModifier < ActiveRecord::Base
  belongs_to :start_line
  belongs_to :parent, :class_name => 'LineModifier'
  has_many :children, :class_name => 'LineModifier', :foreign_key => 'parent_id'
  attr_accessible :start_line_number, :end_address, :end_line_number, :new_characters, :original_characters, :start_address, :subtype, :type

  def chars
      new_characters.chars.to_a
  end

  def mods_at(address)
      children.where(:start_address => address)
  end
end
