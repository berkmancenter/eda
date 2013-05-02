class Stanza < ActiveRecord::Base
  belongs_to :work
  has_many :lines, :dependent => :destroy, :order => 'number'
  attr_accessible :position
end
