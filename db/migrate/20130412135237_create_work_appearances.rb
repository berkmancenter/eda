class CreateWorkAppearances < ActiveRecord::Migration
  def change
    create_table :work_appearances do |t|
      t.references :work
      t.string :publication
      t.integer :year
      t.datetime :date

      t.timestamps
    end
    add_index :work_appearances, :work_id
  end
end
