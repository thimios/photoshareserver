class CreatePhotoReports < ActiveRecord::Migration
  def change
    create_table :photo_reports do |t|
      t.references :user
      t.references :photo

      t.timestamps
    end
    add_index :photo_reports, :user_id
    add_index :photo_reports, :photo_id
  end
end
