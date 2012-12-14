class CreateSystemPhotos < ActiveRecord::Migration
  def change
    create_table :system_photos do |t|
      t.string :title
      t.has_attached_file :image
      t.timestamps
    end
  end
end
