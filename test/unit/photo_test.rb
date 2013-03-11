require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  fixtures :categories, :users, :photos, :quotes, :photo_reports, :named_locations

  test "coordinates_null" do
    first_photo  = Photo.create(title: "first photo", category_id: 1, user_id: 1, latitude: nil, longitude: nil, show_on_map: true)
    assert_equal first_photo.latitude_not_null, 90.0
    assert_equal first_photo.longitude_not_null, 0.0
  end

  test "coordinates_not_null" do
    latitude = 51.2
    longitude = 10.3
    first_photo  = Photo.create(title: "first photo", category_id: 1, user_id: 1, latitude: 51.2, longitude: 10.3, show_on_map: true)
    assert_equal first_photo.latitude_not_null, 51.2
    assert_equal first_photo.longitude_not_null, 10.3
  end

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
