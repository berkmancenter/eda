# == Schema Information
#
# Table name: setts
#
#  id             :integer          not null, primary key
#  name           :text
#  metadata       :text
#  type           :string(255)
#  editable       :boolean
#  nestable_id    :integer
#  nestable_type  :string(255)
#  owner_id       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  level_order    :integer
#  ancestry       :string(255)
#  is_leaf        :boolean          default(TRUE)
#  ancestry_depth :integer          default(0)
#

class Collection < ImageSet
  def self.find_by_name(name_to_find)
    Collection.where(name: name_to_find).first
  end
end
