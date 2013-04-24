# These are changes that Emily made herself on the manuscripts
# Things like cancelations (crossing stuff out) or overwites or turning letters
# into other letters
class Alternate < LineModifier
    def chars
        case subtype
        when 'cancellation'
            original_characters.chars.to_a
        else
            new_characters.chars.to_a
        end
    end
end
