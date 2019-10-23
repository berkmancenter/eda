class AddLevelOrderToSetts < ActiveRecord::Migration[5.2]
  def up
    add_column :setts, :level_order, :integer

    Sett.all.each do |sett|
      sett.update_column :level_order, sett.lft
    end
  end

  def down
    remove_column :setts, :level_order
  end
end
