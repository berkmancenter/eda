FactoryGirl.define do
  factory :edition do
    name "The Poems of Emily Dickinson"
    author "Thomas H. Johnson"
    date "1951-01-01"
    work_number_prefix "J"
    completeness 0.95
  end

  factory :work do
    title "An altered look about the hills"
    number 140
  end



end


