class CreateWordVariants < ActiveRecord::Migration
  def change
    create_table :word_variants do |t|
      t.references :word
      t.string :endings
      t.string :part_of_speech
      t.text :etymology

      t.timestamps
    end
  end
end
