require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  fixtures :categories, :users, :photos, :quotes, :photo_reports, :named_locations

  test "show on map" do

    photo = Photo.first
    photo.update_attribute :show_on_map, true

    photo = Photo.first
    assert_equal true, photo.show_on_map

    photo.update_attribute :show_on_map, false
    photo.save!

    photo = Photo.first
    assert_equal false, photo.show_on_map
  end
end
