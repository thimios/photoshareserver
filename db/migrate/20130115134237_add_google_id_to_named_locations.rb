class AddGoogleIdToNamedLocations < ActiveRecord::Migration
  def change
    add_column :named_locations, :google_id, :string
    add_index :named_locations, :google_id, :unique => true
  end
end
