module SettSorter
  def self.sort_set(id, ids_in_order = nil)
    unless ids_in_order
      s = Sett.find(id)
      kids = s.children
      ids_in_order = kids.sort_by{|k| Naturally.normalize(k.name)}.map(&:id)
    end

    ids_in_order.each_with_index do |kid_id, pos|
      Sett.find(kid_id).update_attribute :level_order_position, pos
    end
  end
end
