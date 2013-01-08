class Photo < ActiveRecord::Base
  acts_as_voteable

  has_many :photo_reports, :inverse_of => :photo, :dependent => :destroy

  # comments
  opinio_subjectum

  acts_as_gmappable :lat => 'latitude', :lng => 'longitude', :process_geocoding => :geocode?,
                    :address => "address", :normalized_address => "address",
                    :msg => "Sorry, not even Google could figure out where that is"

  attr_accessible :category_id, :user_id, :title, :image, :address, :latitude, :longitude, :track_location, :banned, :photo_reports

  searchable do
  	# text :description, :as => :description_textp
    text :title, :as => :title_textp
    integer :category_id, :references => Category, :multiple => false
    integer :user_id, :references => User, :multiple => false
    latlon :coordinates do
      Sunspot::Util::Coordinates.new(latitude, longitude)
    end
    integer :plusminus
    boolean :banned
    time :created_at, :trie => true
  end

  belongs_to :category, :touch => true, :inverse_of => :photos
  belongs_to :user, :touch => false, :inverse_of => :photos
  has_attached_file :image,
                    :styles => { :full => "640x640", :medium => "460x460>", :thumb => "80x80>" }
  def original_size_url
    self.banned? ? Rails.configuration.banned_original_size_url : self.image.url
  end

  def full_size_url
    self.banned? ? Rails.configuration.banned_full_size_url : image.url(:full)
  end

  def medium_size_url
    self.banned? ? Rails.configuration.banned_medium_size_url : image.url(:medium)
  end

  def thumb_size_url
    self.banned? ? Rails.configuration.banned_thumb_size_url : image.url(:thumb)
  end

  def author_name
    user.username
  end

  def reported_count
    self.photo_reports.count
  end

  def author_avatar_thumb_size_url
    user.thumb_size_url
  end

  def comments_count
    self.comments.count
  end

  attr_accessor :current_user

  def voted_by_current_user
    # add whether the current user has voted for it
    if (self.current_user.voted_against?(self))
      return "against"
    elsif (self.current_user.voted_for?(self))
      return "for"
    else
      return "not"
    end
  end

  def reported_by_current_user
    # add whether the current user has voted for it
    if PhotoReport.where("user_id = ? AND photo_id = ?", self.current_user.id, self.id).first
      return true
    else
      return false
    end
  end

  def author_followed_by_current_user
    if self.current_user == user
      return 'self'
    else
      return self.current_user.following?(user)
    end
  end

  # tracked for user's activity feeds
  include PublicActivity::Model
  tracked :owner => proc { |controller, model|
    controller.current_user
  }

  validates :category_id, :presence => true
  validates :title, :presence => true
  validates :title, :length => { :maximum => 23 }
  validates :user_id, :presence => true
  #validate :address_or_coordinates
  validates :image, :attachment_presence => true, :unless => :skip_attachment_validation

  def skip_attachment_validation
    return Rails.env == "test"
  end

  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude

  after_validation :geocode, :if => :address_changed?  # auto-fetch coordinates
  after_validation :reverse_geocode, :if => :longitude_changed? or :latitude_changed? # auto-fetch address

  def created_at_date
    self.created_at.strftime("%d %b. %Y")
  end

  def as_json(options={})
    super(options.reverse_merge(:methods => [ :author_name, :author_avatar_thumb_size_url, :full_size_url, :medium_size_url, :thumb_size_url, :plusminus, :voted_by_current_user, :comments_count, :created_at_date, :author_followed_by_current_user, :reported_by_current_user ]))
  end

  #Points = (clicks + 1) * exp(c1 * distance) * exp(c2 * time)
  #
  #c1 and c2 are negative constants.
  #Distance is the distance between the current location and the picture
  #time the time between the current time and the time the picture was taken.
  #Clicks is the amount of "so berlin" votes the photo has received
  #
  #The constants are:
  #c1 = -7e-4
  #c2 = -1.15e-09
  #Assuming distance in km for c1 and milliseconds for c2.

  def sorting_rate(lat, long)
    distance_in_km = Geocoder::Calculations::distance_between(self, [lat, long], :units => :km)
    time_in_millis = (Time.zone.now - self.created_at) * 1000
    time_in_minutes = time_in_millis / 1000 / 60
    Math.exp( -0.00014192127 * 1000 * 60 * time_in_minutes)

    #"product(
    #    sum(plusminus_i,1),
    #    exp(
    #      product(
    #        product(
    #          -7, exp(-4)
    #        ),
    #        geodist(
    #          coordinates_ll,
    #          #{params[:user_latitude]},
    #          #{params[:user_longitude]}
    #        )
    #      )
    #    ),
    #    exp(
    #      product(
    #          product(
    #            -1.15,
    #            exp(-9)
    #          ),
    #          ms(NOW, created_at_dt)
    #      )
    #    )
    # )"

    return (plusminus + 1) * Math.exp( -7e-4 * distance_in_km) * Math.exp( -1.15e-09 *  time_in_millis)
  end

  def to_csv(lat, long)
    distance_in_km = Geocoder::Calculations::distance_between(self, [lat, long], :units => :km)
    time_in_millis = (Time.zone.now - self.created_at)  * 1000
    csv = []
    csv += [self.id, self.title, self.latitude, self.longitude, distance_in_km, time_in_millis, self.plusminus.to_s, self.created_at, self.sorting_rate( lat, long).to_s ]
  end

  private

    def geocode?
      (!address.blank? && (latitude.blank? || longitude.blank?)) || address_changed?
    end

end
