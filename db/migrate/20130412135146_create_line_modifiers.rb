class CreateLineModifiers < ActiveRecord::Migration
  def change
    create_table :line_modifiers do |t|
      t.references :start_line
      t.integer :start_address
      t.integer :end_line_number
      t.integer :end_address
      t.string :type
      t.string :subtype
      t.text :original_characters
      t.text :new_characters

      t.timestamps
    end
    add_index :line_modifiers, :start_line_id
  end
end
