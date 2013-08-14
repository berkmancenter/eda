# == Schema Information
#
# Table name: setts
#
#  id            :integer          not null, primary key
#  name          :text
#  metadata      :text
#  type          :string(255)
#  editable      :boolean
#  parent_id     :integer
#  lft           :integer
#  rgt           :integer
#  depth         :integer
#  nestable_id   :integer
#  nestable_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Sett < ActiveRecord::Base
    belongs_to :nestable, polymorphic: true
    belongs_to :owner, :class_name => 'User'
    has_many :notes, :as => :notable
    attr_accessible :name, :editable, :type, :metadata
    serialize :metadata
    acts_as_nested_set
    scope :in_editions, lambda { |editions|
        joins(:editions).where(editions: { id: editions.map(&:id) })
    }
    include TheSortableTree::Scopes

    def leaf_after(set)
        after = nil
        catch_next = false
        Sett.each_with_level(leaves) do |child, level|
            if catch_next
                after = child
                break
            end
            catch_next = child.id == set.id
        end
        after
    end

    def leaf_before(set)
        previous = nil
        Sett.each_with_level(leaves) do |child, level|
            if child.id == set.id
                break
            end
            previous = child
        end
        previous
    end

    def leaves_containing(member)
        leaves.where(nestable_id: member.id, nestable_type: member.class.name)
    end

    def empty?
        leaves.empty?
    end
end
