class CreateStanzas < ActiveRecord::Migration[5.2]
  def change
    create_table :stanzas do |t|
      t.references :work
      t.integer :position

      t.timestamps
    end
  end
end
