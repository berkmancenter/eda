class CreateEditions < ActiveRecord::Migration
  def change
    create_table :editions do |t|
      t.string :name
      t.string :author
      t.datetime :date
      t.string :work_number_prefix
      t.integer :completeness
      t.references :owner
      t.text :description

      t.timestamps
    end
    add_index :editions, :owner_id
  end
end
