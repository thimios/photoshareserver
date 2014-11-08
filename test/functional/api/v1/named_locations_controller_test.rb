require 'test_helper'
include Devise::TestHelpers

module Api
  module V1

    class NamedLocationsControllerTest < ActionController::TestCase
      fixtures :categories, :users, :photos, :quotes, :photo_reports, :named_locations, :system_photos
      include TestSunspot

      setup do
        sign_in User.first
      end



      test "suggest only locations with photos" do
        current_user = User.first
        Photo.reindex
        User.reindex
        NamedLocation.reindex
        Sunspot.commit

        get :suggested_followable_locations , {'page' => 1, 'start' => 0, 'limit' => 20, 'user_latitude' => current_user.latitude, 'user_longitude' => current_user.longitude }
        assert_response :success

        data = ActiveSupport::JSON.decode(response.body)
        assert_not_nil data
        assert_equal 1, data['records'].count, "should return exactly one location"

        NamedLocation.first.photos.each {|photo|
          photo.destroy
        }

        get :suggested_followable_locations , {'page' => 1, 'start' => 0, 'limit' => 20, 'user_latitude' => current_user.latitude, 'user_longitude' => current_user.longitude }
        assert_response :success

        data = ActiveSupport::JSON.decode(response.body)
        assert_not_nil data
        assert_equal 0, data['records'].count, "should return no location"

      end

      test "do not suggest locations that are alredy followed or have no photos" do
        current_user = User.first
        Photo.reindex
        User.reindex
        NamedLocation.reindex
        Sunspot.commit

        User.first.follow(NamedLocation.first)

        get :suggested_followable_locations , {'page' => 1, 'start' => 0, 'limit' => 20, 'user_latitude' => current_user.latitude, 'user_longitude' => current_user.longitude }
        assert_response :success

        data = ActiveSupport::JSON.decode(response.body)
        assert_not_nil data
        assert_equal 0, data['records'].count, "should return no location"
      end
    end
  end
end

