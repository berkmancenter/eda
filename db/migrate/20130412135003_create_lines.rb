class CreateLines < ActiveRecord::Migration
  def change
    create_table :lines do |t|
      t.references :stanza
      t.text :text
      t.integer :number

      t.timestamps
    end
    add_index :lines, :stanza_id
  end
end
