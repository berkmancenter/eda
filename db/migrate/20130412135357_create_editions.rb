class CreateEditions < ActiveRecord::Migration
  def change
    create_table :editions do |t|
      t.string :name
      t.string :author
      t.datetime :date
      t.string :work_number_prefix
      t.float :completeness
      t.references :owner
      t.references :root_image_group
      t.text :description

      t.timestamps
    end
    add_index :editions, :owner_id
  end
end
