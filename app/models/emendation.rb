# These are things Franklin put in to correct spelling and punctuation and
# stuff
class Emendation < LineModifier
    # For rendering this with child modifiers
    def chars
        original_characters.chars.to_a
    end
end
