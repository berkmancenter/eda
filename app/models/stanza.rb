class Stanza < ActiveRecord::Base
  belongs_to :work
  has_many :lines, :dependent => :destroy
  attr_accessible :position
end
