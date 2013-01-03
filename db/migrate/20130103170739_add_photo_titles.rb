class AddPhotoTitles < ActiveRecord::Migration
  def up
    # disable activity logging
    PublicActivity.enabled= false

    Photo.all.each{|photo|
      if photo.title.empty?
        photo.title = Faker::Lorem.sentence(2).truncate(23)
        photo.save!
      end

    }
  end

  def down
  end
end
