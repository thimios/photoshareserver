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

  attr_accessor :current_user

  # count users that are following this user
  def total_followers
    self.count_user_followers
  end


  def followed_by_current_user
    # add whether the current user is following this user or not
    if !self.current_user.nil? and self.followed_by?(self.current_user)
      return "true"
    else
      return "false"
    end
  end

end
