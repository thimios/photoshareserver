class Photo < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  require 'api/v1/photo_search'

  after_destroy :reindex_named_location
  after_save :reindex_named_location
  after_update :reindex_named_location


  acts_as_voteable

  has_many :photo_reports, :inverse_of => :photo, :dependent => :destroy

  # comments
  opinio_subjectum

  acts_as_gmappable :lat => 'latitude', :lng => 'longitude', :process_geocoding => :geocode?,
                    :address => "address", :normalized_address => "address",
                    :msg => "Sorry, not even Google could figure out where that is"

  attr_accessible :category_id, :user_id, :named_location_id, :title, :image, :address, :latitude, :longitude, :show_on_map, :banned, :photo_reports

  searchable do
  	# text :description, :as => :description_textp
    text :title, :as => :title_textp
    text :author_name, :as => :author_name_textp
    text :location_name, :as => :location_name_textp
    integer :named_location_id, :references => NamedLocation, :multiple => false
    integer :category_id, :references => Category, :multiple => false
    integer :user_id, :references => User, :multiple => false
    integer :named_location_id, :references => NamedLocation, :multiple => false
    latlon :coordinates do
      Sunspot::Util::Coordinates.new(latitude_not_null, longitude_not_null)
    end
    integer :plusminus
    boolean :show_on_map
    boolean :banned
    time :created_at, :trie => true
    string :named_location_id_str
  end

  def latitude_not_null
    latitude || 90.000
  end

  def longitude_not_null
    longitude || 0.000
  end

  def named_location_id_str
    self.named_location_id.to_s
  end

  belongs_to :category, :touch => true, :inverse_of => :photos
  belongs_to :user, :touch => false, :inverse_of => :photos
  belongs_to :named_location, :touch => true, :inverse_of => :photos

  def reindex_named_location
    unless self.named_location.nil?
      Sunspot.index! self.named_location
    end
  end

  has_attached_file :image,
                    :styles => { :medium => "128x128>", :medium_retina => "256x256>", :thumb => "80x80>" }
  def original_size_url
    self.banned? ? Rails.configuration.banned_original_size_url : self.image.url
  end

  def full_size_url
    self.original_size_url
  end

  def medium_size_url
    self.banned? ? Rails.configuration.banned_medium_size_url : image.url(:medium)
  end

  def medium_retina_size_url
    self.banned? ? Rails.configuration.banned_medium_size_url : image.url(:medium_retina)
  end

  def small_size_url
    self.banned? ? Rails.configuration.banned_thumb_size_url : image.url(:thumb)
  end

  def thumb_size_url
    self.banned? ? Rails.configuration.banned_thumb_size_url : image.url(:thumb)
  end

  # path to the photo details on the web page, to be shared on facebook etc
  def share_path
   home_photo_detail_path(self)
  end

  def author_name
    user.username
  end

  def location_google_id
    self.named_location.nil? ? nil : self.named_location.google_id
  end

  def location_name
    self.named_location.nil? ? nil : self.named_location.name
  end

  def location_vicinity
    self.named_location.nil? ? nil : self.named_location.vicinity
  end

  def location_reference
    self.named_location.nil? ? nil : self.named_location.reference
  end

  def reported_count
    self.photo_reports.count
  end

  def author_avatar_thumb_size_url
    user.thumb_size_url
  end

  attr_accessor :current_user

  def voted_by_current_user
    # add whether the current user has voted for it
    #if (self.current_user.voted_against?(self))
    #  return "against"
    # users can currently vote only for a photo and not against it, also users can only vote on photos
    current_user.voted_for?(self)
  end

  def reported_by_current_user
    # add whether the current user has voted for it
    current_user.reported? self
  end

  def author_followed_by_current_user
    if self.current_user == user
      return 'self'
    else
      return self.current_user.following?(user)
    end
  end

  def location_followed_by_current_user
    if self.named_location.nil?
      return false
    else
      self.named_location.current_user = self.current_user
      self.named_location.followed_by_current_user
    end
  end

  # tracked for user's activity feeds
  include PublicActivity::Model
  tracked :owner => proc { |controller, model|
    controller.current_user
  }

  # destroy all activity records on destroy
  has_many :activities, :class_name => "::PublicActivity::Activity", :as => :trackable, :dependent => :destroy

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

  def plusminus
    self.votes_count
  end

  def as_json(options={})
    super(options.reverse_merge(:methods => [ :author_name, :author_avatar_thumb_size_url, :full_size_url, :medium_size_url, :medium_retina_size_url, :thumb_size_url, :plusminus, :voted_by_current_user, :comments_count, :created_at_date, :author_followed_by_current_user, :reported_by_current_user, :location_reference, :location_google_id, :location_name, :location_vicinity, :location_followed_by_current_user, :share_path ]))
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


  # params_time_factor: position of the slider 0: full left: recent,  4: full right: all time
  # params_distance_factor:  0: full left: nearby, 4: full right: global
  def sorting_rate(lat, long, params_time_factor, params_distance_factor)
    distance_in_km = Geocoder::Calculations::distance_between(self, [lat.round(4), long.round(4)], :units => :km)
    time_in_millis = (Time.zone.now - self.created_at) * 1000

    time_factor = Api::V1::PhotoSearch.time_factor_from_param params_time_factor
    distance_factor = Api::V1::PhotoSearch.distance_factor_from_param params_distance_factor

    #                               "product(
    #                                  sum(plusminus_i,1),
    #                                  1e100,
    #                                  max(
    #                                    product(
    #                                      exp(
    #                                        product(
    #                                          #{distance_factor},
    #                                          geodist(
    #                                            coordinates_ll,
    #                                            #{params[:user_latitude].to_f.round(4)},
    #                                            #{params[:user_longitude].to_f.round(4)}
    #                                          )
    #                                        )
    #                                      ),
    #                                      exp(
    #                                        product(
    #                                          #{time_factor},
    #                                          ms(NOW/HOUR, created_at_dt)
    #                                        )
    #                                      )
    #                                    ),
    #                                    1e-200
    #                                  )
    #                               ) desc".gsub(/\s+/, " ").strip

    return (self.plusminus.to_d + 1.to_d).to_d * 1.0E10 * [Math.exp( distance_factor.to_d * distance_in_km) * Math.exp( time_factor.to_d *  time_in_millis.to_d), 1.0E-200].max
  end

  def to_csv(lat, long, params_time_factor, params_distance_factor)
    distance_in_km = Geocoder::Calculations::distance_between(self, [lat, long], :units => :km)
    time_in_millis = (Time.zone.now - self.created_at)  * 1000
    csv = []
    csv += [self.id, self.title, self.latitude, self.longitude, distance_in_km, time_in_millis, self.plusminus.to_s, self.created_at, self.sorting_rate( lat, long, params_time_factor, params_distance_factor).to_s ]
  end

  private

    def geocode?
      (!address.blank? && (latitude.blank? || longitude.blank?)) || address_changed?
    end

end
