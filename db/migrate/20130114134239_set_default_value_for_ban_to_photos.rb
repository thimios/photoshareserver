class SetDefaultValueForBanToPhotos < ActiveRecord::Migration
  def change
    PublicActivity.enabled = false
    Photo.find_each do |photo|
      if photo.banned.nil?
        photo.banned = false
        photo.save
      end
    end
  end
end
