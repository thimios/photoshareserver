class Photo < ActiveRecord::Base
  acts_as_voteable

  # comments
  opinio_subjectum

  acts_as_gmappable :lat => 'latitude', :lng => 'longitude', :process_geocoding => :geocode?,
                    :address => "address", :normalized_address => "address",
                    :msg => "Sorry, not even Google could figure out where that is"

  attr_accessible :category_id, :user_id, :description, :title, :image, :address, :latitude, :longitude

  searchable do
  	text :description, :title
    integer :category_id, :references => Category, :multiple => false
    latlon :coordinates do
      Sunspot::Util::Coordinates.new(latitude, longitude)
    end
    integer :plusminus
  end

  belongs_to :category, :touch => true, :inverse_of => :photos
  belongs_to :user, :touch => false, :inverse_of => :photos
  has_attached_file :image, :styles => { :full => "800x800", :medium => "300x300>", :thumb => "100x100>" }

  def full_size_url
    image.url
  end

  def medium_size_url
    image.url(:medium)
  end

  def thumb_size_url
    image.url(:thumb)
  end

  def author_name
    user.username
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

  # tracked for user's activity feeds
  include PublicActivity::Model
  tracked :owner => proc { |controller, model| controller.current_user }

  validates :category_id, :presence => true
  validates :title, :presence => true
  #validate :address_or_coordinates
  #validates :image, :attachment_presence => true

  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude

  after_validation :geocode, :if => :address_changed?  # auto-fetch coordinates
  after_validation :reverse_geocode, :if => :longitude_changed? or :latitude_changed? # auto-fetch address



  private

    def geocode?
      (!address.blank? && (latitude.blank? || longitude.blank?)) || address_changed?
    end

end
