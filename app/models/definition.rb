# == Schema Information
#
# Table name: definitions
#
#  id         :integer          not null, primary key
#  word_id    :integer
#  number     :integer
#  definition :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Definition < ActiveRecord::Base
  belongs_to :word_variant
  attr_accessible :definition, :number
  default_scope order(:number)
end
