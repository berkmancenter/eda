# == Schema Information
#
# Table name: line_modifiers
#
#  id                  :integer          not null, primary key
#  work_id             :integer
#  parent_id           :integer
#  start_line_number   :integer
#  start_address       :integer
#  end_line_number     :integer
#  end_address         :integer
#  type                :string(255)
#  subtype             :string(255)
#  original_characters :text
#  new_characters      :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

# These are changes that Emily made herself on the manuscripts
# As opposed to alternate readings, she made these on ink manuscripts with
# pencil (I think that's the distinction)
class Revision < LineModifier
end

