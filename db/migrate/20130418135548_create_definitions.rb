class CreateDefinitions < ActiveRecord::Migration
  def change
    create_table :definitions do |t|
      t.references :word_variant
      t.integer :number
      t.text :definition

      t.timestamps
    end
    add_index :definitions, :word_variant_id
  end
end
