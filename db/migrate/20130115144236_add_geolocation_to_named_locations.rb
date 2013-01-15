class AddGeolocationToNamedLocations < ActiveRecord::Migration
  def change
    add_column :named_locations, :latitude, :float
    add_column :named_locations, :longitude, :float
  end
end
