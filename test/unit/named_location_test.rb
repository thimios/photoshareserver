require 'test_helper'

class NamedLocationTest < ActiveSupport::TestCase
  fixtures :categories, :users, :photos, :named_locations, :system_photos

  test "followed by current user" do
    current_user = User.find(1)
    location = NamedLocation.find(1)

    location.current_user = current_user
    assert_equal "false", location.followed_by_current_user
    current_user.follow location

    assert_equal "true", location.followed_by_current_user
  end

  test "named locations without photos, should have default avatar" do
    location = NamedLocation.find(1)
    location.photos.all.each{|photo| photo.destroy}

    assert_equal 0, location.photos.count
    defaultavatar = SystemPhoto.find_by_title "default avatar"
    assert_not_nil location.small_size_url
    assert_equal defaultavatar.thumb_size_url, location.small_size_url, "locations without photos should have the default avatar"
  end
end
