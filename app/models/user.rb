class User < ActiveRecord::Base
  acts_as_followable
  acts_as_follower

  acts_as_voter
  has_karma(:photos, :as => :submitter, :weight => 0.5)

  has_many :photos, :inverse_of => :user

  has_many :histories, :inverse_of => :owner

  has_many :reports, :inverse_of => :user, :dependent => :destroy

  acts_as_gmappable :lat => 'latitude', :lng => 'longitude', :process_geocoding => :geocode?,
                    :address => "address", :normalized_address => "address",
                    :msg => "Sorry, not even Google could figure out where that is"


  # Include default devise modules. Others available are:
  # :token_authenticatable, :
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :token_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  default_scope :conditions => { :deleted_at => nil }

  # commented out validations are already performed by devise and should not be done twice
  #validates_presence_of     :email
  #validates_presence_of     :password, :on => :create
  #validates_confirmation_of :password, :on => :create
  #validates_length_of       :password, :within => 6..30, :allow_blank => true
  #validates_uniqueness_of   :email, :case_sensitive => false, :scope => :deleted_at
  #validates_format_of       :email, :with => Devise::email_regexp
  validates_presence_of     :username
  validates_uniqueness_of   :username
  validates_presence_of     :birth_date
  validates_presence_of     :gender
  validates_inclusion_of    :gender, :in => %w(male female)

  has_attached_file :avatar,
                    :styles => { :full => "640x640", :medium => "460x460>", :thumb => "80x80>" }

  # if params not nil, will update the location attributes in the database. A solr reindex of that user will be triggered
  def update_location(lat, long)
    unless lat.nil? or long.nil?
      self.update_attribute "latitude", lat
      self.update_attribute "longitude", long
      logger.debug "Updated user coordinates"
    else
      logger.warn "Cannot update user location, since coordinate params are nil."
    end
  end

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
  attr_accessible :username, :birth_date, :gender, :email, :password, :password_confirmation, :remember_me, :address, :latitude, :longitude, :avatar, :admin, :superadmin

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
    text :username, :as => :username_textp
    integer :following_user_ids, :multiple => true
    integer :plusminus
    integer :id
    latlon :coordinates do
      Sunspot::Util::Coordinates.new(latitude, longitude)
    end
  end

  def plusminus
    Vote.joins('LEFT OUTER JOIN photos ON photos.id = votes.voteable_id').where("votes.vote = true AND photos.user_id = ?", self.id).count
  end

  def following_location_ids
    self.following_named_location.map {|item| item.id}
  end

  def following_user_ids
    self.following_user.map {|user| user.id}
  end

  def follower_ids
    self.followers.map {|follower| follower.id}
  end

  def sorting_rate(lat, long)
    distance_in_km = Geocoder::Calculations::distance_between(self, [lat, long], :units => :km)

    return (plusminus + 1) * Math.exp( -7e-4 * distance_in_km)
  end

  def as_json(options={})
    super(options.reverse_merge(:methods => [ :thumb_size_url, :followed_by_current_user, :total_followers, :total_following ]))
  end

  def to_csv(lat, long)
    distance_in_km = Geocoder::Calculations::distance_between(self, [lat, long], :units => :km)

    csv = []
    csv += [self.id, self.username, self.latitude, self.longitude, distance_in_km, self.plusminus.to_s, self.sorting_rate( lat, long).to_s ]
  end

  private

    def geocode?
      (!address.blank? && (latitude.blank? || longitude.blank?)) || address_changed?
    end

end
