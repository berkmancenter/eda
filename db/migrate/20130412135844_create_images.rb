class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.text :title
      t.text :url
      t.text :metadata
      t.text :credits
      t.integer :full_width
      t.integer :full_height
      t.integer :web_width
      t.integer :web_height

      t.timestamps
    end
  end
end
