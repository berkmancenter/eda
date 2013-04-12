class CreatePageGroupPages < ActiveRecord::Migration
  def change
    create_table :page_group_pages do |t|
      t.references :page_group
      t.references :page
      t.integer :position

      t.timestamps
    end
    add_index :page_group_pages, :page_group_id
    add_index :page_group_pages, :page_id
  end
end
