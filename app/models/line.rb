# == Schema Information
#
# Table name: lines
#
#  id         :integer          not null, primary key
#  stanza_id  :integer
#  text       :text
#  number     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Line < ApplicationRecord
  belongs_to :stanza, optional: true
  has_one :work, :through => :stanza
  has_many :line_modifiers, -> (object) {
    where('start_line_number <= ? and end_line_number >= ?', object.number, object.number)
  }, :through => :work
  attr_accessible :number, :text

  after_initialize :load_modifiers
  before_destroy :destroy_mods

  def chars
      text.chars.to_a
  end

  def mods_at(address)
      if @mods.nil?
          output = []
      else
          output = @mods.select{|m| m.start_address == address && m.parent_id == nil}
      end

      output
  end

  def parent
      nil
  end

  def just_author_break?
      line_modifiers.exists?(:subtype => 'author')
  end

  def self.find_by_number(number_to_find)
    Line.where(number: number_to_find).first
  end

  private

  def load_modifiers
      if number.present?
        @mods = line_modifiers.all
      end
  end

  def destroy_mods
      work.line_modifiers.where("start_line_number <= #{number} AND end_line_number >= #{number}").destroy_all
  end
end
