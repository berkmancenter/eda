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

    validates :name, length: { maximum: 1000 }

    serialize :metadata
    has_ancestry cache_depth: true

    include RankedModel
    ranks :level_order, with_same: :parent_id
    default_scope rank(:level_order)

    scope :in_editions, lambda { |editions|
        joins(:editions).where(editions: { id: editions.map(&:id) })
    }

    scope :leafy, where(is_leaf: true)
    scope :parental, where(is_leaf: false)

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

    def leaf?
      is_leaf
    end 

    alias_method :self_and_ancestors, :path
    alias_method :self_and_descendants, :subtree

    def leaves_after(node, num = 1)
      ids = []
      # Look at all our ancestors until our designated root
      node.self_and_ancestors.from_depth(depth + 1).each do |n|
        # Pick all leafy siblings after node
        ids += n.next_siblings.leafy.pluck(:id)
        # Pick all leaves of parental siblings after node
        conditions = []
        n.next_siblings.parental.each do |sib|
          conditions << sib.descendant_conditions
        end
        unless conditions.empty?
          sql = conditions.map(&:first).join(' or ')
          values = conditions.map{|c| c[1, 2]}.flatten
          ids += leaves.where(sql, *values).pluck(:id)
        end
      end

      # Return an activerecord relation so we can chain
      leaves.where(id: ids)
    end

    def leaves_before(set, num = 1)
        leaves.where{rgt < set.lft}.reorder('rgt DESC').limit(num)
    end

    def leaf_after(node)
      # Check this level first
      leaf = leaf_after_and_same_depth_or_deeper(node)
      return leaf unless leaf.empty?

      # Look at all our ancestors until our designated root
      node.ancestors.from_depth(depth + 1).reorder('ancestry_depth DESC').each do |n|
        leaf = leaf_after_and_same_depth_or_deeper(n)
        return leaf unless leaf.empty?
      end

      # Return an activerecord relation so we can chain
      Sett.limit(0)
    end

    def leaf_after_and_same_depth_or_deeper(node)
      # Pick all leafy siblings after node
      leaf = node.next_siblings.leafy.limit(1)
      return leaf unless leaf.empty?

      # Pick all leaves of parental siblings after node
      node.next_siblings.parental.each do |sib|
        leaf = sib.leaves.limit(1)
        return leaf unless leaf.empty?
      end

      Sett.limit(0)
    end

    def leaf_before_and_same_depth_or_deeper(node)
      node.prev_siblings.each do |sib|
        return self.class.find(sib.id) if sib.leaf?
        leaf = sib.leaves.limit(1)
        return leaf unless leaf.empty?
      end

      Sett.limit(0)
    end

    def leaf_before(node)
      # Check this level first
      leaf = leaf_before_and_same_depth_or_deeper(node)
      return leaf unless leaf.empty?

      # Look at all our ancestors until our designated root
      node.ancestors.from_depth(depth + 1).reorder('ancestry_depth DESC').each do |n|
        leaf = leaf_before_and_same_depth_or_deeper(n)
        return leaf unless leaf.empty?
      end

      # Return an activerecord relation so we can chain
      Sett.limit(0)
    end

    def next_siblings
      siblings.where{level_order > my{self.level_order}}
    end

    def prev_siblings
      siblings.where{level_order < my{self.level_order}}.reverse_order
    end

    def position_in_level
        # zero-indexed
        siblings.where{rgt < my{lft}}.count
    end

    def leaves_containing(member)
        leaves.where(nestable_id: ( member.id unless member.nil? ), nestable_type: member.class.name)
    end

    def empty?
        leaves.empty?
    end

    def move_to_child_of(node)
        self.parent = node
    end

    def move_right
      self.update_attribute :level_order_position, :down
      self
    end
    alias_method :move_down, :move_right

    def move_left
      self.update_attribute :level_order_position, :up
      self
    end
    alias_method :move_up, :move_left

    def leaves
        self.descendants.leafy
    end


    def duplicate
        self.class.skip_callback :create, :before, :set_default_left_and_right
        self.class.skip_callback :save, :before, :store_new_parent
        self.class.skip_callback :save, :after, :move_to_new_parent
        self.class.skip_callback :save, :after, :set_depth!

        offset = Sett.maximum('rgt') + 1 - lft

        tree = self_and_descendants.all
        clones = []

        tree.each do |original_item|
            clone = original_item.dup
            clone.lft += offset
            clone.rgt += offset
            clones << clone
        end

        Sett.import clones, validate: false

        cloned_tree = Sett.find_by_lft(offset + lft).self_and_descendants.all

        map = Hash[tree.map(&:id).zip(cloned_tree.map(&:id))]

        Sett.transaction do
            cloned_tree.each do |clone|
                next if clone.root?
                clone.update_column(:parent_id, map[clone.parent_id])
                clone.save!
            end
        end

        self.class.set_callback :create, :before, :set_default_left_and_right
        self.class.set_callback :save, :before, :store_new_parent
        self.class.set_callback :save, :after, :move_to_new_parent
        self.class.set_callback :save, :after, :set_depth!

        cloned_tree.first
    end
end
