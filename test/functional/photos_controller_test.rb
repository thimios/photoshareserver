require 'test_helper'
include Devise::TestHelpers


class PhotosControllerTest < ActionController::TestCase
  fixtures :categories, :users, :photos, :quotes, :photo_reports, :named_locations
  include TestSunspot

  setup do
    sign_in User.first
    @generator = Random.new
  end

  test "delete all reported photos" do
    assert_difference('Photo.count',-1) do
      get :destroy_all_reported
    end
  end

  test "get all photos of user, sorted by created_at desc" do

  end


end

