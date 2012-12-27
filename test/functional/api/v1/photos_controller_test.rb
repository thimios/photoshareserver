require 'test_helper'

include Devise::TestHelpers


module Api
  module V1

    class PhotosControllerTest < ActionController::TestCase
      include TestSunspot

      setup do
        sign_in User.first
      end

      test "test photo sorting algorithm" do
        # category_id=1&page=1&user_latitude=52.488909&user_longitude=13.421728

        generator = Random.new
        imagefile = File.open(File.join(Rails.root, 'app', 'assets', 'images', 'seed.jpg'))
        20.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: generator.rand(1..2), latitude: generator.rand(52.2..54.7), longitude: generator.rand(12.3..14.5), image: imagefile, track_location: "yes")
        end

        Photo.reindex
        Sunspot.commit

        first_photo = Photo.first

        get :index , {'category_id' => 1, 'page' => 1, 'user_latitude' => first_photo.latitude, 'user_longitude' => first_photo.longitude }
        assert_response :success

        photos = assigns(:photos)

        previous_photo_rate = photos.first.sorting_rate first_photo.latitude, first_photo.longitude
        photos.each { |photo|
          rate = photo.sorting_rate(first_photo.latitude, first_photo.longitude)
          assert  ( previous_photo_rate >= rate ) , "wrong sorting order of photos"
          previous_photo_rate = rate
        }


      end


    end
  end
end
