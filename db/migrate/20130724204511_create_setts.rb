class CreateSetts < ActiveRecord::Migration[5.2]
  def change
    create_table :setts do |t|
      t.text :name
      t.text :metadata
      t.string :type
      t.boolean :editable
      t.references :parent
      t.integer :lft
      t.integer :rgt
      t.integer :depth
      t.references :nestable
      t.string :nestable_type
      t.references :owner

      t.timestamps
    end
    add_index :setts, :lft
    add_index :setts, :rgt
    add_index :setts, :nestable_type
    add_index :setts, :type
  end
end
