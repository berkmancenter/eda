# These are divisions in the manuscript that Franklin did not show in his text
# because he assumed it was because of paper constraints
class Division < LineModifier
    scope :page_breaks, where(subtype: 'page_or_column')
end
