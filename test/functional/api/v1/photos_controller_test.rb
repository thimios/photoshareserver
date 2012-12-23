require 'test_helper'
include Devise::TestHelpers

module Api
  module V1

    class PhotosControllerTest < ActionController::TestCase
      setup do
        sign_in User.first
        @photo_one = photos(:one)
        @photo_two = photos(:two)

        Photo.reindex
        Sunspot.commit
      end

      test "should get index" do
        # category_id=1&page=1&user_latitude=52.488909&user_longitude=13.421728

        results = Photo.search do
          fulltext "{!func}geodist(location_ll, #{photos(:one).latitude}, #{photos(:one).longitude})"
          order_by(:score, :asc)
        end

        post = results.hits.first.result
        distance = results.hits.first.score

        geocoder_distance = Geocoder::Calculations::distance_between(photos(:one), photos(:two), :units => :km)

        get :index , {'category_id' => 1, 'page' => 1, 'user_latitude' => photos(:one).latitude, 'user_longitude' => photos(:one).longitude }
        body = JSON.parse(response.body)

        assert_response :success

      end


    end
  end
end
