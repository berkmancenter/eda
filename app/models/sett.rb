class Sett < ActiveRecord::Base
    belongs_to :nestable, polymorphic: true
    belongs_to :owner, :class_name => 'User'
    attr_accessible :name, :editable, :type, :metadata
    serialize :metadata
    acts_as_nested_set
    include TheSortableTree::Scopes

    def leaf_containing(member)
        leaves.where(nestable_id: member.id, nestable_type: member.class.name).first
    end
end