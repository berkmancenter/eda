class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.string :title
      t.datetime :date
      t.integer :number
      t.references :edition
      t.references :page_group
      t.text :metadata

      t.timestamps
    end
    add_index :works, :edition_id
    add_index :works, :page_group_id
  end
end
