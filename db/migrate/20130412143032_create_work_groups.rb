class CreateWorkGroups < ActiveRecord::Migration
  def change
    create_table :work_groups do |t|
      t.string :name
      t.string :type
      t.references :parent_group
      t.references :edition
      t.references :owner
      t.integer :position

      t.timestamps
    end
    add_index :work_groups, :parent_group_id
    add_index :work_groups, :edition_id
    add_index :work_groups, :owner_id
  end
end
