class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable
  devise :ldap_authenticatable, :trackable, :timeoutable

  validates :name, presence: true
  validates :email, presence: true
  validates_uniqueness_of :email

  default_scope { order(name: :asc) }

  ROLES = %w(admin user none manager)

  def ldap_before_save
    begin
      lde = self.ldap_entry
      if self.name.blank?
        self.name = lde[:givenName].first + " " + lde[:sn].first
      end
      #self.title = lde[:title].first if self.title.blank?
      #self.department = lde[:department].first if self.department.blank?
    rescue Exception => e
      Rails.logger.error(e.message)
    end
    # make the first user and admin
    self.add_role :admin if User.count == 0
  end
end
