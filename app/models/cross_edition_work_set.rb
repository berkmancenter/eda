# == Schema Information
#
# Table name: setts
#
#  id            :integer          not null, primary key
#  name          :text
#  metadata      :text
#  type          :string(255)
#  editable      :boolean
#  parent_id     :integer
#  lft           :integer
#  rgt           :integer
#  depth         :integer
#  nestable_id   :integer
#  nestable_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CrossEditionWorkSet < WorkSet
end
