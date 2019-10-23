# == Schema Information
#
# Table name: stanzas
#
#  id         :integer          not null, primary key
#  work_id    :integer
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Stanza < ActiveRecord::Base
  belongs_to :work
  has_many :lines, -> { order('number') }, :dependent => :destroy
  attr_accessible :position
end
