class CreateImageGroups < ActiveRecord::Migration
  def change
    create_table :image_groups do |t|
      t.text :name
      t.boolean :editable
      t.text :image_url
      t.text :metadata
      t.references :edition
      t.string :type
      t.references :parent
      t.integer :lft
      t.integer :rgt

      t.timestamps
    end
    add_index :image_groups, :parent_id
    add_index :image_groups, :lft
    add_index :image_groups, :rgt
    add_index :image_groups, :edition_id
  end
end
