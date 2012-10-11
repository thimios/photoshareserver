class Photo < ActiveRecord::Base
  acts_as_voteable

  acts_as_gmappable :lat => 'latitude', :lng => 'longitude', :process_geocoding => :geocode?,
                    :address => "address", :normalized_address => "address",
                    :msg => "Sorry, not even Google could figure out where that is"

  attr_accessible :category_id, :description, :title, :image, :address, :latitude, :longitude

  searchable do
  	text :description, :title
    integer :category_id, :references => Category, :multiple => false
    latlon :coordinates do
      Sunspot::Util::Coordinates.new(latitude, longitude)
    end
    integer :plusminus
  end

  belongs_to :category, :touch => true, :inverse_of => :photos
  has_attached_file :image, :styles => { :full => "800x800", :medium => "300x300>", :thumb => "100x100>" }

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
