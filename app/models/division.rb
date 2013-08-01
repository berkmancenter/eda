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

# These are divisions in the manuscript that Franklin did not show in his text
# because he assumed it was because of paper constraints
class Division < LineModifier
    scope :page_breaks, where(subtype: 'page_or_column')
end
