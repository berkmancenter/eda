class CreateImageGroups < ActiveRecord::Migration
  def change
    create_table :image_groups do |t|
      t.string :name
      t.references :parent_group
      t.boolean :editable
      t.text :image_url
      t.text :metadata
      t.references :edition
      t.string :type
      t.integer :position

      t.timestamps
    end
    add_index :image_groups, :parent_group_id
    add_index :image_groups, :edition_id
  end
end
