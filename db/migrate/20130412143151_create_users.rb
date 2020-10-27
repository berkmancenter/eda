class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
        t.references :current_edition

      t.timestamps
    end
  end
end
