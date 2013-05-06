class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.references :edition
      t.references :work
      t.references :image_group_image

      t.timestamps
    end
    add_index :pages, :edition_id
    add_index :pages, :work_id
    add_index :pages, :image_group_image_id
  end
end
