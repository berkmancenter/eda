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

    def matching_node_in(set)
        # Maybe do this by nestable?
        return unless root.self_and_descendants.count == set.root.self_and_descendants.count
        offset = set.root.lft - root.lft
        set.descendants.where(lft: lft + offset, rgt: rgt + offset).first
    end

    def lft=(left)
        write_attribute(:lft, left)
    end

    def rgt=(right)
        write_attribute(:rgt, right)
    end

    def leaves_after(set, num = 1)
        leaves.where{lft > set.rgt}.order(:lft).limit(num)
    end

    def leaves_before(set, num = 1)
        leaves.where{rgt < set.lft}.reorder('rgt DESC').limit(num)
    end

    def leaf_after(set)
        leaves_after(set).first
    end

    def leaf_before(set)
        leaves_before(set).first
    end

    def position_in_level
        # zero-indexed
        siblings.where{rgt < my{lft}}.count
    end

    def leaves_containing(member)
        leaves.where(nestable_id: member.id, nestable_type: member.class.name)
    end

    def empty?
        leaves.empty?
    end

    def duplicate
        self.class.skip_callback :create, :before, :set_default_left_and_right
        self.class.skip_callback :save, :before, :store_new_parent
        self.class.skip_callback :save, :after, :move_to_new_parent, :set_depth!

        offset = Sett.maximum('rgt') + 1 - lft

        root_clone = dup
        root_clone.lft += offset
        root_clone.rgt += offset
        root_clone.save!
        map = {self => root_clone}

        descendants = self.descendants.all

        descendants.each do |original_item|
            clone = original_item.dup
            clone.lft += offset
            clone.rgt += offset
            map[original_item] = clone
            clone.save!
        end

        descendants.each do |original_item|
            next if original_item.root?
            clone = map[original_item]
            clone.parent_id = map[original_item.parent].id
            clone.save!
        end

        self.class.set_callback :create, :before, :set_default_left_and_right
        self.class.set_callback :save, :before, :store_new_parent
        self.class.set_callback :save, :after, :move_to_new_parent, :set_depth!

        root_clone
    end
end
