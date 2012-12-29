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

        photo_count_low_rate = 60
        photo_count_high_rate = 60
        photo_count = photo_count_low_rate + photo_count_high_rate

        generator = Random.new
        imagefile = File.open(File.join(Rails.root, 'app', 'assets', 'images', 'seed.jpg'))

        #creating first photo
        first_photo  = Photo.create(title: "first photo", category_id: 1, user_id: generator.rand(1..2), latitude: 52.2, longitude: 12.3, track_location: "yes")
        first_photo.save
        users = User.order('RAND()').limit(10)
        users.each {|user|
          user.vote_for (first_photo)
        }


        photo_count_high_rate.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: generator.rand(1..2), latitude: generator.rand(52.2..59.7), longitude: generator.rand(12.3..17.5), track_location: "yes")
          photo.created_at = rand(0.2..0.7).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        photo_count_low_rate.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: generator.rand(1..2), latitude: generator.rand(52.2..54.7), longitude: generator.rand(12.3..14.5), track_location: "yes")
          photo.created_at = rand(0..2000).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        Photo.reindex
        Sunspot.commit



        get :index , {'category_id' => 1, 'page' => 1, 'start' => 0, 'limit' => photo_count, 'user_latitude' => first_photo.latitude, 'user_longitude' => first_photo.longitude }
        assert_response :success

        photos = assigns(:photos)

        csv = CSV.generate(:force_quotes => true) do |line|
          line <<["id", "title", "latitude", "longitude", "distance in km",  "time in millis", "votes", "created_at", "sorting_rate"]

          previous_photo_rate = photos.first.sorting_rate first_photo.latitude, first_photo.longitude
          photos.each { |photo|
            line << photo.to_csv(first_photo.latitude, first_photo.longitude)
            rate = photo.sorting_rate(first_photo.latitude, first_photo.longitude)
            assert  ( previous_photo_rate >= rate ) , "wrong sorting order of photos: previous rate: #{previous_photo_rate} this rate: #{rate}"
            previous_photo_rate = rate
          }
        end

        File.open(File.join(Rails.root, 'test', 'results', "#{Time.now.to_s}.csv"), "w"){ |file| file.write csv }
      end
    end
  end
end
