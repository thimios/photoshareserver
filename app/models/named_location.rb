class NamedLocation < ActiveRecord::Base
  acts_as_followable #users can follow named locations

  attr_accessible :reference, :google_id, :latitude, :longitude, :name, :vicinity
  has_many :photos, :inverse_of => :named_location, :dependent => :nullify

  validates_presence_of     :reference
  validates_uniqueness_of   :reference
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
    time :created_at, :trie => true
  end

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

  def small_size_url
    search = Sunspot.search (Photo) do
      with(:named_location_id,  self.id)
      order_by :plusminus, :desc
      paginate :page => 1, :per_page => 1
    end

    unless search.results.empty?
      return search.results.first.small_size_url
    else
      return nil
    end

  end

  def followed_by_current_user
    # add whether the current user is following this user or not
    if !self.current_user.nil? and self.followed_by?(self.current_user)
      return "true"
    else
      return "false"
    end
  end

  def as_json(options={})
    super(options.reverse_merge(:methods => [ :small_size_url, :followed_by_current_user ]))
  end

end
