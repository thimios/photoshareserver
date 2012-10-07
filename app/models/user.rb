class User < ActiveRecord::Base
  acts_as_voter
  has_karma(:photos, :as => :submitter, :weight => 0.5)


  # Include default devise modules. Others available are:
  # :token_authenticatable, :
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :token_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  default_scope :conditions => { :deleted_at => nil }
  validates_presence_of     :email
  validates_presence_of     :password, :on => :create
  validates_confirmation_of :password, :on => :create
  validates_length_of       :password, :within => 6..30, :allow_blank => true
  #validates_uniqueness_of   :email, :case_sensitive => false, :scope => :deleted_at
  validates_format_of       :email, :with => Devise::email_regexp
  validates_presence_of     :username
  validates_uniqueness_of   :username
  validates_presence_of     :birth_date
  validates_presence_of     :gender
  validates_inclusion_of    :gender, :in => %w(male female)

  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :birth_date, :gender, :email, :password, :password_confirmation, :remember_me

  def destroy
    self.update_attribute(:deleted_at, Time.now.utc)
  end

  def self.find_with_destroyed *args
    self.with_exclusive_scope { find(*args) }
  end

  def self.find_only_destroyed
    self.with_exclusive_scope :find => { :conditions => "deleted_at IS NOT NULL" } do
      all
    end
  end
end
