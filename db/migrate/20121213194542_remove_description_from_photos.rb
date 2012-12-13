class RemoveDescriptionFromPhotos < ActiveRecord::Migration
  def up
    remove_column :photos, :description
  end

  def down
    add_column :photos, :description, :text
  end
end
