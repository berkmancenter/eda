class CreateStanzas < ActiveRecord::Migration
  def change
    create_table :stanzas do |t|
      t.references :work
      t.integer :position

      t.timestamps
    end
    add_index :stanzas, :work_id
  end
end
