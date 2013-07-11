class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.string :title
      t.datetime :date
      t.integer :number
      t.string :variant
      t.references :edition
      t.references :image_group
      t.references :cross_edition_work_group
      t.text :metadata

      t.timestamps
    end
    add_index :works, :edition_id
    add_index :works, :image_group_id
  end
end
