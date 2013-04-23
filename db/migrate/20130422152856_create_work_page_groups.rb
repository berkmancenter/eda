class CreateWorkPageGroups < ActiveRecord::Migration
  def change
    create_table :work_page_groups do |t|
      t.references :work
      t.references :page_group

      t.timestamps
    end
    add_index :work_page_groups, :work_id
    add_index :work_page_groups, :page_group_id
  end
end
