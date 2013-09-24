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

class Line < ActiveRecord::Base
  belongs_to :stanza
  has_one :work, :through => :stanza
  has_many :line_modifiers, :through => :work, :conditions => proc{ "start_line_number <= #{number} AND end_line_number >= #{number}" }
  attr_accessible :number, :text

  after_initialize :load_modifiers
  before_destroy :destroy_mods

  def chars
      text.chars.to_a
  end

  def mods_at(address)
      @mods.select{|m| m.start_address == address && m.parent_id == nil}
      #work.line_modifiers.all.select{|lm| lm.start_address == address && lm.start_line_number <= number && (lm.end_line_number >= number || lm.end_line_number.nil?)}
  end

  def parent
      nil
  end

  def just_author_break?
      line_modifiers.exists?(:subtype => 'author')
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
