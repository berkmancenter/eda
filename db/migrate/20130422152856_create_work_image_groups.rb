class CreateWorkImageGroups < ActiveRecord::Migration
  def change
    create_table :work_image_groups do |t|
      t.references :work
      t.references :image_group

      t.timestamps
    end
    add_index :work_image_groups, :work_id
    add_index :work_image_groups, :image_group_id
  end
end
