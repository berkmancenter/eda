class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :image_url
      t.text :metadata
      t.text :credits

      t.timestamps
    end
  end
end
