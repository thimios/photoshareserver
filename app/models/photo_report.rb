class PhotoReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :photo, :counter_cache => true
  attr_accessible :photo_id, :user_id
end
