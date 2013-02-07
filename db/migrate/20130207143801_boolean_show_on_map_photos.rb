class BooleanShowOnMapPhotos < ActiveRecord::Migration
  def change
    change_column :photos, :show_on_map, :boolean, :default => false
  end
end
