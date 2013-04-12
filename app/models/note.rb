class Note < ActiveRecord::Base
  belongs_to :owner
  attr_accessible :notable_id, :notable_type, :note
end
