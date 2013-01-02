class AddDefaultValueForBanToPhotos < ActiveRecord::Migration
  def change
    change_column :photos, :banned, :boolean, :default => false
  end
end
