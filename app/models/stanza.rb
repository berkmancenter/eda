class Stanza < ActiveRecord::Base
  belongs_to :work
  attr_accessible :position
end
