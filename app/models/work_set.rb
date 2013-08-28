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

class WorkSet < Sett
    alias_attribute :work, :nestable

    def work=(work)
        self.nestable = work
    end

    def all_works
        self_and_descendants.map{|work_set| work_set.work}.compact
    end

    def name
        read_attribute(:name) || (work.full_title if work)
    end
end
