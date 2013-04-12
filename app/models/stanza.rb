class Stanza < ActiveRecord::Base
  belongs_to :work
  has_many :lines
  attr_accessible :position
end
