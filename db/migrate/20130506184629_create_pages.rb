class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.references :edition
      t.references :work_set
      t.references :image_set

      t.timestamps
    end
    add_index :pages, :edition_id
    add_index :pages, :work_set_id
    add_index :pages, :image_set_id
  end
end
