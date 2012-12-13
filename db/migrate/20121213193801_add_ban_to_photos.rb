class AddBanToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :banned, :boolean
  end
end
