require 'test_helper'

class NamedLocationTest < ActiveSupport::TestCase
  fixtures :categories, :users, :photos, :named_locations

  test "followed by current user" do
    current_user = User.find(1)
    location = NamedLocation.find(1)

    location.current_user = current_user
    assert_equal "false", location.followed_by_current_user

    current_user.follow location

    assert_equal "true", location.followed_by_current_user
  end
end
