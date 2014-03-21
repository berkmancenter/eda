# == Schema Information
#
# Table name: setts
#
#  id             :integer          not null, primary key
#  name           :text
#  metadata       :text
#  type           :string(255)
#  editable       :boolean
#  nestable_id    :integer
#  nestable_type  :string(255)
#  owner_id       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  level_order    :integer
#  ancestry       :string(255)
#  is_leaf        :boolean          default(TRUE)
#  ancestry_depth :integer          default(0)
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
