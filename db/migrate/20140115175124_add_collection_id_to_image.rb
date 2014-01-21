class AddCollectionIdToImage < ActiveRecord::Migration
  def up
    add_column :images, :collection_id, :integer
    add_index :images, :collection_id

    Collection.roots.each do |c|
      c.all_images.each do |i|
        i.update_column('collection_id', c.id)
      end
    end
  end

  def down
    remove_column :images, :collection_id
    remove_index :images, :collection_id
  end
end
