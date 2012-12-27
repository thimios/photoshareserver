require 'test_helper'


include Devise::TestHelpers


module Api
  module V1

    class PhotosControllerTest < ActionController::TestCase
      include TestSunspot

      setup do
        sign_in User.first
      end

      test "test photo sorting algorithm, random distances" do
        # /api/v1/photos.json?_dc=1356628364027&auth_token=Hy4JzyV8XVxpDtt7rStj&user_latitude=37.0435203&user_longitude=22.110219000000004&page=1&start=0&limit=10&filter=%5B%7B%22property%22%3A%22category_id%22%2C%22value%22%3A%221%22%7D%5D

        generator = Random.new
        imagefile = File.open(File.join(Rails.root, 'app', 'assets', 'images', 'seed.jpg'))
        3.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: generator.rand(1..2), latitude: generator.rand(52.2..54.7), longitude: generator.rand(12.3..14.5), image: imagefile, track_location: "yes")
        end

        Photo.reindex
        Sunspot.commit

        first_photo = Photo.first

        get :index , {'category_id' => 1, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => first_photo.latitude, 'user_longitude' => first_photo.longitude }
        assert_response :success

        photos = assigns(:photos)

        csv = CSV.generate(:force_quotes => true) do |line|
          line <<["id", "title", "latitude", "longitude", "plusminus", "created_at", "sorting_rate"]

          previous_photo_rate = photos.first.sorting_rate first_photo.latitude, first_photo.longitude
          photos.each { |photo|
            line << photo.to_csv(first_photo.latitude, first_photo.longitude)
            rate = photo.sorting_rate(first_photo.latitude, first_photo.longitude)
            assert  ( previous_photo_rate >= rate ) , "wrong sorting order of photos"
            previous_photo_rate = rate
          }
        end

        File.open(File.join(Rails.root, 'test', 'results', "#{Time.now.to_s}.csv"), "w"){ |file| file.write csv }
      end



    end
  end
end
