class LimitPhotoTitleLength < ActiveRecord::Migration
  def up
    Photo.all.each{|photo|
      if photo.title.length > 23
        photo.title.truncate(23)
        photo.save
      end

    }
  end

  def down
  end
end
