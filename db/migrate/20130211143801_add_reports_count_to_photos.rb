class AddReportsCountToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :photo_reports_count, :integer, :default => 0

    Photo.reset_column_information
    Photo.find_each do |p|
      Photo.update_counters p.id, :photo_reports_count => p.photo_reports.length
    end
  end

  def self.down
    remove_column :photos, :photo_reports_count
  end
end
