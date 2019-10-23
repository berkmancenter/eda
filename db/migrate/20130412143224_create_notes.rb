class CreateNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :notes do |t|
      t.integer :notable_id
      t.string :notable_type
      t.text :note
      t.references :owner

      t.timestamps
    end
  end
end
