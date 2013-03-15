require 'test_helper'
include Devise::TestHelpers



module Api
  module V1

    class SortingAlgorithmTest < ActionController::TestCase
      fixtures :categories, :users
      include TestSunspot

      setup do
        sign_in User.first
        @generator = Random.new
        @controller = Api::V1::PhotosController.new
      end

      test "photo sorting algorithm, random distances" do
        # /api/v1/photos.json?_dc=1356628364027&auth_token=Hy4JzyV8XVxpDtt7rStj&user_latitude=37.0435203&user_longitude=22.110219000000004&page=1&start=0&limit=10&filter=%5B%7B%22property%22%3A%22category_id%22%2C%22value%22%3A%221%22%7D%5D

        photo_count = 40

        #creating first photo
        first_photo  = Photo.create(title: "reference photo", category_id: 1, user_id: @generator.rand(1..2), latitude: 51.2, longitude: 10.3, show_on_map: true)

        users = User.order('RAND()').limit(10)
        users.each {|user|
          user.vote_for (first_photo)
        }

        photo_count.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: @generator.rand(1..2), latitude: @generator.rand(40.2..52.7), longitude: @generator.rand(-74.0..29.5), show_on_map: true)
          photo.created_at = rand(2..20000).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        Photo.reindex
        Sunspot.commit

        # Using sliders in the middle, passing no params[:time_factor] params[:distance_factor]
        get :index , {'category_id' => 1, 'page' => 1, 'start' => 0, 'limit' => 300, 'user_latitude' => first_photo.latitude, 'user_longitude' => first_photo.longitude }
        assert_response :success

        photos = assigns(:photos)

        csv = CSV.generate(:force_quotes => true) do |line|
          line <<["id", "title", "latitude", "longitude", "distance in km",  "time in millis", "votes", "created_at", "sorting_rate"]

          previous_photo_rate = photos.first.sorting_rate first_photo.latitude, first_photo.longitude, nil,nil
          photos.each { |photo|
            line << photo.to_csv(first_photo.latitude, first_photo.longitude, nil, nil)
            rate = photo.sorting_rate(first_photo.latitude, first_photo.longitude, nil, nil)
            #assert previous_photo_rate >= rate, "wrong sorting order of photos when sliders in the middle: previous rate: #{previous_photo_rate} this rate: #{rate}"
            previous_photo_rate = rate
          }
        end
        FileUtils.mkdir_p File.join(Rails.root, 'test', 'results', 'photos')
        File.open(File.join(Rails.root, 'test', 'results', 'photos', "#{Time.now.to_s}.sliders.in.the.middle.csv"), "w"){ |file| file.write csv }

        # Using sliders in the far left, recent, nearby, passing  params[:time_factor]=0 params[:distance_factor]=0
        params_time_factor = "0"
        params_distance_factor = "0"
        get :index , {'time_factor' => params_time_factor, 'distance_factor' => params_distance_factor, 'category_id' => 1, 'page' => 1, 'start' => 0, 'limit' => 300, 'user_latitude' => first_photo.latitude, 'user_longitude' => first_photo.longitude }
        assert_response :success

        photos = assigns(:photos)

        csv = CSV.generate(:force_quotes => true) do |line|
          line <<["id", "title", "latitude", "longitude", "distance in km",  "time in millis", "votes", "created_at", "sorting_rate"]

          previous_photo_rate = photos.first.sorting_rate first_photo.latitude, first_photo.longitude, params_time_factor, params_distance_factor
          photos.each { |photo|
            line << photo.to_csv(first_photo.latitude, first_photo.longitude, params_time_factor, params_distance_factor)
            rate = photo.sorting_rate(first_photo.latitude, first_photo.longitude, params_time_factor, params_distance_factor)
            #assert previous_photo_rate >= rate, "wrong sorting order of photos when sliders in the left: previous rate: #{previous_photo_rate} this rate: #{rate}"
            previous_photo_rate = rate
          }
        end
        FileUtils.mkdir_p File.join(Rails.root, 'test', 'results', 'photos')
        File.open(File.join(Rails.root, 'test', 'results', 'photos', "#{Time.now.to_s}.sliders.in.the.left.csv"), "w"){ |file| file.write csv }
      end


    end
  end
end
