class CreateLines < ActiveRecord::Migration[5.2]
  def change
    create_table :lines do |t|
      t.references :stanza
      t.text :text
      t.integer :number

      t.timestamps
    end
  end
end
