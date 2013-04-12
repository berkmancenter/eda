class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :notable_id
      t.string :notable_type
      t.text :note
      t.references :owner

      t.timestamps
    end
    add_index :notes, :owner_id
  end
end
