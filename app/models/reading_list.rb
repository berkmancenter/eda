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

class ReadingList < WorkSet
    alias_method :works, :all_works

    validates :name, presence: true

    def works=(new_works)
        existing_works = works
        existing_work_ids = existing_works.map(&:id)
        new_work_ids = new_works.map(&:id)

        new = new_work_ids - existing_work_ids
        updated = new_work_ids & existing_work_ids
        deleted = existing_work_ids - new_work_ids

        new.each do |id|
            add_work(new_works.find{|w| w.id == id}, true)
        end

        updated.each do |id|
            existing_works.find{|w| w.id == id}.touch
        end

        deleted.each do |id|
            leaves_containing(existing_works.find{|w| w.id == id}).destroy_all
        end
    end

    def add_work(work, skip_check = false)
        return if contains_work?(work) unless skip_check
        c = WorkSet.new
        c.work = work
        c.move_to_child_of(self)
        c.save!
    end

    def contains_work?(work)
        !leaves_containing(work).empty?
    end
end
