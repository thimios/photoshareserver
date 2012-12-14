class Photo < ActiveRecord::Base
  acts_as_voteable

  has_many :photo_reports, :inverse_of => :photo, :dependent => :destroy

  # comments
  opinio_subjectum

  acts_as_gmappable :lat => 'latitude', :lng => 'longitude', :process_geocoding => :geocode?,
                    :address => "address", :normalized_address => "address",
                    :msg => "Sorry, not even Google could figure out where that is"

  attr_accessible :category_id, :user_id, :title, :image, :address, :latitude, :longitude, :track_location, :banned

  searchable do
  	# text :description, :as => :description_textp
    text :title, :as => :title_textp
    integer :category_id, :references => Category, :multiple => false
    integer :user_id, :references => User, :multiple => false
    latlon :coordinates do
      Sunspot::Util::Coordinates.new(latitude, longitude)
    end
    integer :plusminus
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
  tracked :owner => proc { |controller, model| controller.current_user }

  validates :category_id, :presence => true
  #validates :title, :presence => true
  validates :user_id, :presence => true
  #validate :address_or_coordinates
  validates :image, :attachment_presence => true

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

  private

    def geocode?
      (!address.blank? && (latitude.blank? || longitude.blank?)) || address_changed?
    end

end
