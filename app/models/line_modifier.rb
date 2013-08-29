# == Schema Information
#
# Table name: line_modifiers
#
#  id                  :integer          not null, primary key
#  work_id             :integer
#  parent_id           :integer
#  start_line_number   :integer
#  start_address       :integer
#  end_line_number     :integer
#  end_address         :integer
#  type                :string(255)
#  subtype             :string(255)
#  original_characters :text
#  new_characters      :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class LineModifier < ActiveRecord::Base
  belongs_to :start_line
  belongs_to :work
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
