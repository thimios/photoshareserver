class CreateNamedLocations < ActiveRecord::Migration
  def change
    create_table :named_locations do |t|
      t.string :reference

      t.timestamps
    end
    add_index :named_locations, :reference, :unique => true
  end
end
