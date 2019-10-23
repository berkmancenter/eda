class CreateWorks < ActiveRecord::Migration[5.2]
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
  end
end
