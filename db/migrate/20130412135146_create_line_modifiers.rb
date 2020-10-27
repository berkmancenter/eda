class CreateLineModifiers < ActiveRecord::Migration[5.2]
  def change
    create_table :line_modifiers do |t|
      t.references :work
      t.integer :parent_id
      t.integer :start_line_number
      t.integer :start_address
      t.integer :end_line_number
      t.integer :end_address
      t.string :type
      t.string :subtype
      t.text :original_characters
      t.text :new_characters

      t.timestamps
    end
  end
end
