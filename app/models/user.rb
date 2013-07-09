class User < ActiveRecord::Base
    belongs_to :current_edition, :class_name => 'Edition'
    has_many :notes, :inverse_of => :owner

    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable

    # Setup accessible (or protected) attributes for your model
    attr_accessible :email, :password, :password_confirmation, :remember_me
    attr_accessible :email

    before_create :set_defaults

    def note_for(notable)
        notable.notes.where(:owner_id => id).first
    end

    private

    def set_defaults
        self.current_edition = Edition.find_by_name(Eda::Application.config.emily['default_edition'])
    end
end
