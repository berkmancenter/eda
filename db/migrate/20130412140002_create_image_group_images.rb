class CreateImageGroupImages < ActiveRecord::Migration
  def change
    create_table :image_group_images do |t|
      t.references :image_group
      t.references :image
      t.integer :position

      t.timestamps
    end
    add_index :image_group_images, :image_group_id
    add_index :image_group_images, :image_id
  end
end
