# == Schema Information
#
# Table name: setts
#
#  id             :integer          not null, primary key
#  name           :text
#  metadata       :text
#  type           :string(255)
#  editable       :boolean
#  nestable_id    :integer
#  nestable_type  :string(255)
#  owner_id       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  level_order    :integer
#  ancestry       :string(255)
#  is_leaf        :boolean          default(TRUE)
#  ancestry_depth :integer          default(0)
#

class Sett < ApplicationRecord
    belongs_to :nestable, polymorphic: true, optional: true
    belongs_to :owner, :class_name => 'User', optional: true
    has_many :notes, :as => :notable
    attr_accessible :name, :editable, :type, :metadata

    validates :name, length: { maximum: 1000 }

    serialize :metadata
    has_ancestry cache_depth: true

    include RankedModel
    include ::TheSortableTree::Scopes
    ranks :level_order, with_same: :ancestry

    default_scope { rank(:level_order) }

    scope :in_editions, lambda { |editions|
        joins(:editions).where(editions: { id: editions.map(&:id) })
    }

    scope :nested_set, -> {
      rank(:level_order)
    }

    scope :reversed_nested_set, -> {
      rank(:level_order).reverse_order
    }

    scope :leafy, -> {
      where(is_leaf: true)
    }

    scope :parental, -> {
      where(is_leaf: false)
    }

    alias_method :self_and_ancestors, :path

    before_save :update_leaf_status

    def self_and_descendants
      nodes_in_order = Sett.sort_by_ancestry(subtree){|a, b| a.level_order <=> b.level_order}
      ids_in_order = nodes_in_order.map(&:id)
      Sett.where(id: ids_in_order).reorder(Arel.sql("position(CAST(id AS text) in '#{ids_in_order.join(' ')}')"))
    end

    def leaf?
      is_leaf
    end

    def leaves_before(node)
      # Order isn't guaranteed
      ids = []
      # Look at all our ancestors until our designated root
      node.self_and_ancestors.from_depth(depth + 1).each do |n|
        # Pick all leafy siblings before node
        ids += n.prev_siblings.leafy.pluck(:id)
        # Pick all leaves of parental siblings before node
        conditions = []
        n.prev_siblings.parental.each do |sib|
          conditions << sib.descendant_conditions
        end
        unless conditions.empty?
          conditions_raw = []
          conditions.each do |condition|
            conditions_raw << Sett.where(condition).arel.constraints.reduce(:and).to_sql
          end
          ids += leaves.where(conditions_raw.join(' OR ')).pluck(:id)
        end
      end

      # Return an activerecord relation so we can chain
      leaves.where(id: ids)
    end

    def leaves_after(node)
      # Order isn't guaranteed
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
          conditions_raw = []
          conditions.each do |condition|
            conditions_raw << Sett.where(condition).arel.constraints.reduce(:and).to_sql
          end
          ids += leaves.where(conditions_raw.join(' OR ')).pluck(:id)
        end
      end

      # Return an activerecord relation so we can chain
      leaves.where(id: ids)
    end

    def leaf_after(node)
      # Check this level first
      leaf = leaf_after_and_same_depth_or_deeper(node)
      return leaf unless leaf.nil?

      # Look at all our ancestors until our designated root
      node.ancestors.from_depth(depth + 1).reorder('ancestry_depth DESC').each do |n|
        leaf = leaf_after_and_same_depth_or_deeper(n)
        return leaf unless leaf.nil?
      end
      nil
    end

    def leaf_after_and_same_depth_or_deeper(node)
      node.next_siblings.each do |sib|
        return sib if sib.leaf?
        leaf = sib.leaves.limit(1)
        return leaf.first unless leaf.empty?
      end
      nil
    end

    def leaf_before_and_same_depth_or_deeper(node)
      node.prev_siblings.each do |sib|
        return sib if sib.leaf?
        leaf = sib.leaves.reorder('ancestry_depth ASC, level_order DESC').limit(1)
        return leaf.first unless leaf.empty?
      end
      nil
    end

    def leaf_before(node)
      # Check this level first
      leaf = leaf_before_and_same_depth_or_deeper(node)
      return leaf unless leaf.nil?

      # Look at all our ancestors until our designated root
      node.ancestors.from_depth(depth + 1).reorder('ancestry_depth DESC').each do |n|
        leaf = leaf_before_and_same_depth_or_deeper(n)
        return leaf unless leaf.nil?
      end
      nil
    end

    def next_siblings
      if root?
        self.class.none
      else
        siblings.where('level_order > ?', self.level_order)
      end
    end

    def prev_siblings
      if root?
        self.class.none
      else
        siblings.where('level_order < ?', self.level_order).reverse_order
      end
    end

    def position_in_level
        # zero-indexed
        prev_siblings.count
    end

    def leaves_containing(member)
        leaves.where(
          nestable_id: ( member.id unless member.nil? ),
          nestable_type: member.class.name
        )
    end

    def empty?
        leaves.empty?
    end

    def move_to_child_of(node)
        self.parent = node
        self.level_order_position = :last
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
      new_root = self.dup
      new_root.save

      new_nodes = []
      new_to_old_ids = {}
      new_root_id = new_root.id
      i = 1
      # Duplicate descendants
      descendants.each do |node|
        new_node = node.dup
        new_nodes[node.id] = new_node
        new_node.id = new_root_id + i
        new_to_old_ids[node.id] = new_node.id
        without_ancestry_callbacks do
          new_node.nestable = node.nestable
        end
        new_node.move_to_child_of new_root
        i += 1
      end

      new_to_old_ids[id] = new_root_id

      # Update ancestry with new ids of duplicated items
      descendants.each do |node|
        without_ancestry_callbacks do
          new_nodes[node.id].ancestry = node.ancestor_ids.map do |ancestor_id|
            matched_id = new_to_old_ids[ancestor_id]

            ancestor_id = matched_id unless matched_id.nil?

            ancestor_id
          end.join('/')
        end
      end

      Sett.import new_nodes.compact, validate: false
      # Requires postgres
      ActiveRecord::Base.connection.reset_pk_sequence!(Sett.table_name)
      new_root
    end

    private

    def update_leaf_status
      if !root? && parent.is_leaf
        parent.update_attribute :is_leaf, false
      end
    end
end
