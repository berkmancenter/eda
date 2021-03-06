class CreateEditions < ActiveRecord::Migration[5.2]
  def change
    create_table :editions do |t|
      t.string :name
      t.string :short_name
      t.string :citation
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
    add_index :editions, :completeness
  end
end
