class WorkSet < Sett
    alias_attribute :work, :nestable

    def work=(work)
        self.nestable = work
    end

    def all_works
        self_and_descendants.map{|work_set| work_set.work}.compact
    end

    def name
        read_attribute(:name) || work.full_title
    end
end
