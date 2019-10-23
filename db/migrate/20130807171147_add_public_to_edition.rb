class AddPublicToEdition < ActiveRecord::Migration[5.2]
  def change
    add_column :editions, :public, :boolean
  end
end
