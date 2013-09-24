# == Schema Information
#
# Table name: editions
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  author             :string(255)
#  date               :datetime
#  work_number_prefix :string(255)
#  completeness       :float
#  description        :text
#  owner_id           :integer
#  work_set_id        :integer
#  image_set_id       :integer
#  parent_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Edition < ActiveRecord::Base
    belongs_to :owner, :class_name => 'User'
    belongs_to :parent, :class_name => 'Edition'
    belongs_to :image_set, dependent: :destroy
    belongs_to :work_set, dependent: :destroy

    has_many :works, dependent: :destroy #, after_add: :add_work_to_work_set

    attr_accessible :author, :completeness, :date, :description, :name,
        :work_number_prefix, :parent_id, :public, :short_name, :citation

    validates :name, presence: true, length: { maximum: 200 }
    validates :description, length: { maximum: 2000 }
    validates :author, length: { maximum: 200 }
    validates :date, length: { maximum: 200 }
    validates :work_number_prefix, length: { maximum: 6 }

    scope :is_public, where(public: true)
    scope :for_user, lambda { |user|
        if user.nil?
            is_public
        else
            joins{owner.outer}.where{(owner.id == my{user.id}) | (public == true)}
        end
    }
    default_scope order(:completeness)

    before_create :setup_sets, :setup_name

    def images
        image_set.all_images
    end

    def all_works
        if is_child?
            this_editions_works = works.all
            Work.where(id:
               parent.works.all.map(&:id) -
               this_editions_works.map(&:revises_work_id) +
               this_editions_works.map(&:id)
            )
        else
            works
        end
    end

    def is_child?
        !parent.nil?
    end

    private

    def add_work_to_work_set(work)
        ws = WorkSet.new
        work.edition = self
        ws.work = work
        ws.save!
        ws.move_to_child_of work_set
    end

    def copy_tree_from_parent(relation)
        root = parent.send(relation)
        self.send("#{relation}=", root.duplicate)
    end

    def setup_name
        self.short_name = name unless self.short_name
    end

    def setup_sets
        if image_set.nil?
            if is_child?
                copy_tree_from_parent(:image_set)
            else
                self.image_set = ImageSet.create
            end
        end
        if work_set.nil?
            self.work_set = WorkSet.create
        end
    end
end
