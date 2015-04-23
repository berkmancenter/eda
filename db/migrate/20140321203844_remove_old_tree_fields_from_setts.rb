class RemoveOldTreeFieldsFromSetts < ActiveRecord::Migration
  def up
    remove_column :setts, :parent_id
    remove_column :setts, :lft
    remove_column :setts, :rgt
    remove_column :setts, :depth
  end

  def down
    add_column :setts, :parent_id, :integer
    add_column :setts, :lft, :integer
    add_column :setts, :rgt, :integer
    add_column :setts, :depth, :integer
    add_index :setts, :parent_id
    add_index :setts, :lft
    add_index :setts, :rgt

    puts "
    Don't forget to run:
    Sett.all.each{|s| s.update_attribute :parent_id, s.parent_id }
    Sett.rebuild!
    "
  end
end
