class Edition < ActiveRecord::Base
    belongs_to :owner, :class_name => 'User'
    belongs_to :parent, :class_name => 'Edition'
    belongs_to :image_set
    belongs_to :work_set

    has_many :pages do
        def with_image(image)
            where(image_set_id: proxy_association.owner.image_set.leaf_containing(image).id)
        end
        def with_work(work)
            where(work_set_id: proxy_association.owner.work_set.leaf_containing(work).id)
        end
    end
    has_many :works, after_add: :add_work_to_work_set

    attr_accessible :author, :completeness, :date, :description, :name, :work_number_prefix, :parent_id
    default_scope order(:completeness)

    def all_works
        if parent
            this_editions_works = works.all
            Work.where(id: parent.works.all.map(&:id) - this_editions_works.map(&:revises_work_id) + this_editions_works.map(&:id))
        else
            works
        end
    end

    def inherited_everything_yet?
        !(work_set.nil? || image_set.nil? || pages.nil?)
    end

    def replace_work_in_pages!(old, new)
        work_set_with_new_work = work_set.leaf_containing(new)
        pages.with_work(old).each do |page|
            page.work_set = work_set_with_new_work
            page.save!
        end
    end

    def copy_everything_from_parent!
        return unless work_set.nil? && image_set.nil?
        work_map = copy_tree_from_parent(:work_set)
        image_map = copy_tree_from_parent(:image_set)

        copy_pages_from_parent(work_map, image_map)
    end

    private

    def add_work_to_work_set(work)
        ws = WorkSet.new
        ws.work = work
        ws.save!
        ws.move_to_child_of work_set
    end

    def copy_pages_from_parent(work_map, image_map)
        parent.pages.each do |page|
            p = self.pages.new
            p.work_set = work_map[page.work_set]
            p.image_set = image_map[page.image_set]
            p.save!
        end
    end

    def copy_tree_from_parent(relation)
        root = parent.send(relation)
        root_clone = root.dup
        h = {root => root_clone}

        descendants = root.descendants.all
        descendants.each do |item|
            h[item] = item.dup
        end
        descendants.each do |item|
            cloned = h[item]
            cloned_parent = h[item.parent]
            cloned_parent.children << cloned if cloned_parent
        end

        self.send("#{relation}=", root_clone)
        save!
        h
    end
end
