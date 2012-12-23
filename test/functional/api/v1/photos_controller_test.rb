require 'test_helper'
include Devise::TestHelpers

module Api
  module V1

    class PhotosControllerTest < ActionController::TestCase
      setup do
        sign_in User.first
        Photo.reindex
        Sunspot.commit
      end

      test "should get index" do
        # category_id=1&page=1&user_latitude=52.488909&user_longitude=13.421728

        get :index , {'category_id' => 1, 'page' => 1, 'user_latitude' => 52.488909, 'user_longitude' => 13.421728 }
        body = JSON.parse(response.body)
        assert_response :success

      end


    end
  end
end
