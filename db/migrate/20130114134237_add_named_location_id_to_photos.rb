class AddNamedLocationIdToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :named_location_id, :integer
  end
end
