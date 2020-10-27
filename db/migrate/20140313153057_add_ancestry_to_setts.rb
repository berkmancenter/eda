class AddAncestryToSetts < ActiveRecord::Migration[5.2]
  def up
    add_column :setts, :ancestry, :string
    add_index :setts, :ancestry
    add_column :setts, :is_leaf, :boolean, :default => true
    add_index :setts, :is_leaf
    add_column :setts, :ancestry_depth, :integer, :default => 0
    add_index :setts, :ancestry_depth

    parent_ids = Sett.unscoped.select(:parent_id).uniq.map{|s| s.read_attribute(:parent_id)}.compact
    Sett.where(:id => parent_ids).each do |sett|
      sett.update_column :is_leaf, false
    end
  end

  def down
    remove_column :setts, :ancestry
    remove_column :setts, :is_leaf
    remove_column :setts, :ancestry_depth
  end
end
