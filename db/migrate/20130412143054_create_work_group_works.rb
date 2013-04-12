class CreateWorkGroupWorks < ActiveRecord::Migration
  def change
    create_table :work_group_works do |t|
      t.references :work_group
      t.references :work
      t.integer :position

      t.timestamps
    end
    add_index :work_group_works, :work_group_id
    add_index :work_group_works, :work_id
  end
end
