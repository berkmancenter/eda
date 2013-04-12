class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.text :image_url
      t.text :metadata
      t.text :credits

      t.timestamps
    end
  end
end
