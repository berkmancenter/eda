# == Schema Information
#
# Table name: notes
#
#  id           :integer          not null, primary key
#  notable_id   :integer
#  notable_type :string(255)
#  note         :text
#  owner_id     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Note < ApplicationRecord
    belongs_to :owner, :class_name => 'User'
    belongs_to :notable, :polymorphic => true
    attr_accessible :notable_id, :notable_type, :note
end
