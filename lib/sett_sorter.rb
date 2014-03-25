module SettSorter
  def self.sort_set(id)
    s = Sett.find(id)
    kids = s.children
    ids_in_order = kids.sort_by{|k| Naturally.normalize(k.name)}.map(&:id)
    ids_in_order.each_with_index do |id, pos|
      Sett.find(id).update_attribute :level_order_position, pos
    end
  end
end
