class AddVotesCountToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :votes_count, :integer, :default => 0

    Photo.reset_column_information
    Photo.find_each do |p|
      Photo.update_counters p.id, :votes_count => p.votes_for
    end
  end

  def self.down
    remove_column :photos, :votes_count
  end
end
