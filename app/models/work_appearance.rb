class WorkAppearance < ActiveRecord::Base
  belongs_to :work
  attr_accessible :date, :publication, :pages, :year
end
