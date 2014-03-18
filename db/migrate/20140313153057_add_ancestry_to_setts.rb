class AddAncestryToSetts < ActiveRecord::Migration
  def up
    add_column :setts, :ancestry, :string
    add_index :setts, :ancestry
    add_column :setts, :is_leaf, :boolean, :default => true
    add_index :setts, :is_leaf

    parent_ids = Sett.select(:parent_id).uniq.map{|s| s.read_attribute(:parent_id)}.compact
    Sett.where(:id => parent_ids).each do |sett|
      sett.update_column :is_leaf, false
    end

    Sett.build_ancestry_from_parent_ids!
  end

  def down
    remove_index :setts, :ancestry
    remove_column :setts, :ancestry
    remove_index :setts, :is_leaf
    remove_column :setts, :is_leaf
  end
end
