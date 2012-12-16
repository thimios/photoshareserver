class LimitPhotoTitleLength < ActiveRecord::Migration
  def up
    # disable activity logging
    PublicActivity.enabled= false

    Photo.all.each{|photo|
      if photo.title.length > 23
        photo.title = photo.title.truncate(23)
        photo.save!
      end

    }
  end

  def down
  end
end
