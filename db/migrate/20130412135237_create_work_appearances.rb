class CreateWorkAppearances < ActiveRecord::Migration[5.2]
  def change
    create_table :work_appearances do |t|
      t.references :work
      t.string :publication
      t.string :pages
      t.integer :year
      t.datetime :date

      t.timestamps
    end
  end
end
