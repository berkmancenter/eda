# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  current_edition_id     :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#

class User < ActiveRecord::Base
    belongs_to :current_edition, :class_name => 'Edition'
    has_many :notes, :inverse_of => :owner
    has_many :reading_lists, :foreign_key => 'owner_id'
    has_many :editions, :foreign_key => 'owner_id'

    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable

    # Setup accessible (or protected) attributes for your model
    attr_accessible :email, :password, :password_confirmation, :remember_me
    attr_accessible :email

    before_create :set_defaults
    after_create :create_reading_list

    def note_for(notable)
        return unless notable.notes
        notable.notes.where(:owner_id => id).first
    end

    private

    def set_defaults
        self.current_edition = Edition.find_by_name(Eda::Application.config.emily['default_edition'])
    end

    def create_reading_list
        reading_lists.create(name: I18n.t(:default_reading_list))
    end
end
