class Line < ActiveRecord::Base
  belongs_to :stanza
  has_one :work, :through => :stanza
  has_many :line_modifiers, :through => :work, :conditions => proc{ "start_line_number <= #{number} AND end_line_number >= #{number}" }
  attr_accessible :number, :text

  def chars
      text.chars.to_a
  end

  def mods_at(address)
      line_modifiers.where(:start_address => address)
  end

  def parent
      nil
  end

  def just_author_break?
      line_modifiers.exists?(:subtype => 'author')
  end
end
