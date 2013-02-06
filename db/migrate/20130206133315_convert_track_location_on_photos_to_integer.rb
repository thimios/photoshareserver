class ConvertTrackLocationOnPhotosToInteger < ActiveRecord::Migration

  def self.up
    add_column :photos, :show_on_map, :integer
    execute "UPDATE photos SET show_on_map = 0 WHERE track_location='no'"
    execute "UPDATE photos SET show_on_map = 1 WHERE track_location='yes'"
    remove_column :photos, :track_location
  end

  def self.down
    add_column :photos, :track_location, :string
    execute "UPDATE photos SET track_location='no' WHERE show_on_map=0"
    execute "UPDATE photos SET track_location='yes' WHERE show_on_map=1"
    remove_column :photos, :show_on_map
  end

end

