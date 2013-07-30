class CreateEditions < ActiveRecord::Migration
  def change
    create_table :editions do |t|
      t.string :name
      t.string :author
      t.datetime :date
      t.string :work_number_prefix
      t.float :completeness
      t.text :description
      t.references :owner
      t.references :work_set
      t.references :image_set
      t.references :parent

      t.timestamps
    end
    add_index :editions, :owner_id
    add_index :editions, :parent_id
    add_index :editions, :work_set_id
    add_index :editions, :image_set_id
    add_index :editions, :completeness
  end
end
