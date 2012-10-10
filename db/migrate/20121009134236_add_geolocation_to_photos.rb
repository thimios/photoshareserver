class AddGeolocationToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :address, :string
    add_column :photos, :latitude, :float
    add_column :photos, :longitude, :float
  end
end
