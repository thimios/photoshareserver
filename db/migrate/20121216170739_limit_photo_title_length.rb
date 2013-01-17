class LimitPhotoTitleLength < ActiveRecord::Migration
  def up
    # disable activity logging
    PublicActivity.enabled= false

    Photo.all.each{|photo|
      if photo.title.length > 23
        title = photo.title
        photo.update_attribute :title, title.truncate(23)
      end

    }
  end

  def down
  end
end
