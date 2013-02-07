require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  test "track location string attribute" do
    imagefile = File.open(File.join(Rails.root, 'app', 'assets', 'images', 'defaultavatar.png'))

    photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: 1, latitude: 52.2, longitude: 12.3, image: imagefile, track_location: "yes"))
    assert true, photo.show_on_map
  end
end
