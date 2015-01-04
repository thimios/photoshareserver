# Named locations have geo cords and many photos
class NamedLocation < ActiveRecord::Base
  acts_as_followable #users can follow named locations

  attr_accessible :reference, :google_id, :latitude, :longitude, :name, :vicinity
  has_many :photos, :inverse_of => :named_location, :dependent => :nullify

  validates_presence_of     :reference
  validates_presence_of     :google_id
  validates_uniqueness_of   :google_id
  validates_presence_of     :latitude
  validates_uniqueness_of   :latitude
  validates_presence_of     :longitude
  validates_uniqueness_of   :longitude
  validates_presence_of     :name
  validates_presence_of     :vicinity

  searchable do
    text :name, :as => :name_textp
    text :vicinity, :as => :vicinity_textp
    text :google_id
    latlon :coordinates do
      Sunspot::Util::Coordinates.new(latitude, longitude)
    end
    integer :plusminus
    integer :id
    integer :photos_count
    time :created_at, :trie => true
  end

  def photos_count
    self.photos.count
  end

  # Count the votes that all the locations photos have received
  def plusminus
    Vote.joins('LEFT OUTER JOIN photos ON photos.id = votes.voteable_id').where("votes.vote = true AND photos.named_location_id = ?", self.id).count
  end

  # count users that are following this location
  def total_followers
    self.count_user_followers
  end

  attr_accessor :current_user

  # count users that are following this user
  def total_followers
    self.count_user_followers
  end

  def best_photo
    search = Sunspot.search (Photo) do
      with(:named_location_id,  self.id)
      order_by :plusminus, :desc
      paginate :page => 1, :per_page => 1
    end

    unless search.results.empty?
      return search.results.first
    else
      # named locations that have no photo, will appear with the default avatar
      return nil
    end
  end

  def small_size_url
    photo = best_photo
    unless photo.nil?
      return photo.small_size_url
    else
      # named locations that have no photo, will appear with the default avatar
      return (SystemPhoto.find_by_title "default avatar").thumb_size_url
    end
  end

  def followed_by_current_user
    # add whether the current user is following this named location or not
    if !self.current_user.nil? and self.current_user.following_location_ids.include?(self.id)
      return "true"
    else
      return "false"
    end
  end

  def as_json(options={})
    super(options.reverse_merge(:methods => [ :small_size_url, :followed_by_current_user ]))
  end

end
