class AddImageSetNameIndex < ActiveRecord::Migration
  def up
    add_index :setts, :name
  end

  def down
    remove_index :setts, :name
  end
end
