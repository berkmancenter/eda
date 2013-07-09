class Note < ActiveRecord::Base
    belongs_to :owner, :class_name => 'User'
    belongs_to :notable, :polymorphic => true
    attr_accessible :notable_id, :notable_type, :note
end
