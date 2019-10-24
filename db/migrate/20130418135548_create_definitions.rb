class CreateDefinitions < ActiveRecord::Migration[5.2]
  def change
    create_table :definitions do |t|
      t.references :word_variant
      t.integer :number
      t.text :definition

      t.timestamps
    end
  end
end
