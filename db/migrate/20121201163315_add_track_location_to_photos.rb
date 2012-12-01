class AddTrackLocationToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :track_location, :string
  end
end
