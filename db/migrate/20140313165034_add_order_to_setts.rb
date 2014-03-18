class AddOrderToSetts < ActiveRecord::Migration
  def up
    add_column :setts, :order, :integer

    Sett.all.each do |sett|
      sett.update_column :order, sett.lft
    end
  end

  def down
    remove_column :setts, :order
  end
end
