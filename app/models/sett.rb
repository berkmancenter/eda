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

class Sett < ActiveRecord::Base
    belongs_to :nestable, polymorphic: true
    belongs_to :owner, :class_name => 'User'
    has_many :notes, :as => :notable
    attr_accessible :name, :editable, :type, :metadata

    validates :name, length: { maximum: 1000 }

    serialize :metadata
    has_ancestry cache_depth: true

    include RankedModel
    include TheSortableTree::Scopes
    ranks :level_order, with_same: :ancestry

    default_scope rank(:level_order)

    scope :in_editions, lambda { |editions|
        joins(:editions).where(editions: { id: editions.map(&:id) })
    }
    scope :nested_set, rank(:level_order)
    scope :reversed_nested_set, rank(:level_order).reverse_order

    scope :leafy, where(is_leaf: true)
    scope :parental, where(is_leaf: false)

    alias_method :self_and_ancestors, :path
    alias_method :self_and_descendants, :subtree

    def leaf?
      is_leaf
    end 

    def leaves_after(node, num = 1)
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
          sql = conditions.map(&:first).join(' or ')
          values = conditions.map{|c| c[1, 2]}.flatten
          ids += leaves.where(sql, *values).pluck(:id)
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

    def leaves_before(node)
      # Order isn't guaranteed
      ids = []
      # Look at all our ancestors until our designated root
      node.self_and_ancestors.from_depth(depth + 1).each do |n|
        # Pick all leafy siblings after node
        ids += n.prev_siblings.leafy.pluck(:id)
        # Pick all leaves of parental siblings after node
        conditions = []
        n.prev_siblings.parental.each do |sib|
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
        leaf = sib.leaves.limit(1)
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
      siblings.where{level_order > my{self.level_order}}
    end

    def prev_siblings
      siblings.where{level_order < my{self.level_order}}.reverse_order
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
      new_id = new_root.id
      id_difference = new_id - id

      new_nodes = []
      descendants.each do |node|
        new_node = node.dup
        new_nodes << new_node
        new_node.id = node.id + id_difference
        without_ancestry_callbacks do 
          new_node.ancestry = node.ancestor_ids.map{ |i| i + id_difference}.join('/')
          new_node.nestable = node.nestable
        end
      end
      Sett.import new_nodes, validate: false
      new_root
    end
end
