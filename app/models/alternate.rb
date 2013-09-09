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
# Things like cancelations (crossing stuff out) or overwites or turning letters
# into other letters
class Alternate < LineModifier
    def chars
        case subtype
        when 'cancellation'
            original_characters ? original_characters.chars.to_a : []
        else
            new_characters.chars.to_a
        end
    end
end
