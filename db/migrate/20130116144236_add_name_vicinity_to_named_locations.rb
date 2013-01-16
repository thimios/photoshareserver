class AddNameVicinityToNamedLocations < ActiveRecord::Migration
  def change
    add_column :named_locations, :name, :string
    add_column :named_locations, :vicinity, :string
  end
end
