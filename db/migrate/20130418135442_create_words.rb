class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :word
      t.string :endings
      t.string :part_of_speech

      t.timestamps
    end
  end
end
