class AddPublicToEdition < ActiveRecord::Migration
  def change
    add_column :editions, :public, :boolean
  end
end
