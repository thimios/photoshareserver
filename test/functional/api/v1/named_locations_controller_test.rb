require 'test_helper'
include Devise::TestHelpers

module Api
  module V1

    class NamedLocationsControllerTest < ActionController::TestCase
      fixtures :categories, :users, :photos, :quotes, :photo_reports, :named_locations
      include TestSunspot

      setup do
        sign_in User.first
      end

      test "test suggested locations" do
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
        assert_equal 1, data['records'].count, "should return exactly one location"

      end


    end
  end
end

