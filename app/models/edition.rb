# == Schema Information
#
# Table name: editions
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  short_name         :string(255)
#  citation           :string(255)
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
#  public             :boolean
#

class Edition < ApplicationRecord
    belongs_to :owner, :class_name => 'User', optional: true
    belongs_to :parent, :class_name => 'Edition', optional: true
    belongs_to :image_set, dependent: :destroy, optional: true
    belongs_to :work_set, dependent: :destroy, optional: true

    has_many :works, dependent: :destroy

    attr_accessible :author, :completeness, :date, :description, :name,
        :work_number_prefix, :parent_id, :public, :short_name, :citation

    validates :name, presence: true, length: { maximum: 200 }
    validates :description, length: { maximum: 2000 }
    validates :author, length: { maximum: 200 }
    validates :date, length: { maximum: 200 }
    validates :work_number_prefix, length: { maximum: 6 }

    scope :is_public, -> { where('public=true') }
    scope :for_user, lambda { |user|
        if user.nil?
            is_public
        else
            left_outer_joins(:owner).where('owner_id = ? OR public = true', user.id)
        end
    }
    default_scope { order(:completeness) }

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

    def self.find_by_work_number_prefix(prefix_to_find)
      Edition.where(work_number_prefix: prefix_to_find).first
    end

    def self.find_by_image_set_id(image_set_id_to_find)
      Edition.where(image_set_id: image_set_id_to_find).first
    end

    def self.find_by_author(author_to_find)
      Edition.where(author: author_to_find).first
    end

    private

    def add_work_to_work_set(work)
        ws = WorkSet.new
        work.edition = self
        ws.work = work
        ws.save!
        ws.move_to_child_of work_set
        ws.save!
    end

    def copy_tree_from_parent(relation)
        root = parent.send(relation)
        self.send("#{relation}=", root.duplicate)
    end

    def setup_name
        self.short_name = name if self.short_name.empty?
    end

    def setup_sets
        if image_set.nil?
            if is_child?
                copy_tree_from_parent(:image_set)
            else
                self.image_set = Eda::Application.config.emily['default_edition'].image_set.duplicate
            end
        end
        if work_set.nil?
            self.work_set = WorkSet.create
        end
    end
end
