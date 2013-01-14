class NamedLocation < ActiveRecord::Base
  acts_as_followable #users can follow named locations

  attr_accessible :reference
  has_many :photos, :inverse_of => :named_location, :dependent => :nullify

  validates_presence_of     :reference
  validates_uniqueness_of   :reference

  # count users that are following this location
  def total_followers
    self.count_user_followers
  end

end
