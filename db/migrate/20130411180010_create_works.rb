class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.string :title
      t.datetime :date
      t.integer :number
      t.string :variant
      t.boolean :secondary_source
      t.text :metadata
      t.references :edition
      t.references :image_set
      t.references :revises_work

      t.timestamps
    end
    add_index :works, :edition_id
    add_index :works, :image_set_id
    add_index :works, :revises_work_id
  end
end
