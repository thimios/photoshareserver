class PhotoReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :photo
  attr_accessible :photo_id, :user_id
end
