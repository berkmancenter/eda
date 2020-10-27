# == Schema Information
#
# Table name: work_appearances
#
#  id          :integer          not null, primary key
#  work_id     :integer
#  publication :string(255)
#  pages       :string(255)
#  year        :integer
#  date        :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class WorkAppearance < ApplicationRecord
  belongs_to :work, optional: true
  has_many :notes, as: :notable
  attr_accessible :date, :publication, :pages, :year
end
