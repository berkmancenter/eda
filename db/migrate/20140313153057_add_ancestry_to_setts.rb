class AddAncestryToSetts < ActiveRecord::Migration
  def change
    add_column :setts, :ancestry, :string
    add_index :setts, :ancestry
  end
end
