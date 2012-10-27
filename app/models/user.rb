class User < ActiveRecord::Base
  acts_as_followable
  acts_as_follower

  acts_as_voter
  has_karma(:photos, :as => :submitter, :weight => 0.5)

  has_many :photos, :inverse_of => :user

  has_many :histories, :inverse_of => :owner

  acts_as_gmappable :lat => 'latitude', :lng => 'longitude', :process_geocoding => :geocode?,
                    :address => "address", :normalized_address => "address",
                    :msg => "Sorry, not even Google could figure out where that is"


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

  has_attached_file :avatar, :styles => { :full => "800x800", :medium => "300x300>", :thumb => "80x80>" }

  def full_size_url
    avatar.url
  end

  def medium_size_url
    avatar.url(:medium)
  end

  def thumb_size_url
    avatar.url(:thumb)
  end

  attr_accessor :current_user

  # count users that are following this user
  def total_followers
    self.count_user_followers
  end
  # count users followed by this user
  def total_following
    self.following_users_count
  end

  def followed_by_current_user
    # add whether the current user is following this user or not
    if !self.current_user.nil? and self.followed_by?(self.current_user)
      return "true"
    else
      return "false"
    end
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :birth_date, :gender, :email, :password, :password_confirmation, :remember_me, :address, :latitude, :longitude, :avatar

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

  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude

  after_validation :geocode, :if => :address_changed?  # auto-fetch coordinates
  after_validation :reverse_geocode, :if => :longitude_changed? or :latitude_changed? # auto-fetch address

  searchable do
    text :username
    latlon :coordinates do
      Sunspot::Util::Coordinates.new(latitude, longitude)
    end
  end

  #def as_json(options={})
  #  super(
  #      :methods => [ :thumb_size_url],
  #      :except => [:email, :address,:longitude, :latitude, :gender, :birth_date ]
  #  )
  #end

  def as_json(options={})
    super(options.reverse_merge(:methods => [ :thumb_size_url, :followed_by_current_user, :total_followers, :total_following ]))
  end

  private

    def geocode?
      (!address.blank? && (latitude.blank? || longitude.blank?)) || address_changed?
    end

end
