require 'test_helper'
include Devise::TestHelpers


module Api
  module V1

    class RegistrationsControllerTest < ActionController::TestCase
      include TestSunspot

      setup do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in User.first
      end

      test "test suggested users" do
        # /api/v1/users/suggested.json?_dc=1356628364027&auth_token=Hy4JzyV8XVxpDtt7rStj&user_latitude=37.0435203&user_longitude=22.110219000000004&page=1&start=0&limit=20
        generator = Random.new
        User.all.each do |user|
          user.update_attribute :latitude, generator.rand(52.2..59.7)
          user.update_attribute :longitude, generator.rand(12.3..17.5)
        end
        User.first.follow User.all.second
        current_user = User.first

        assert_equal User.first.following_user_ids[0], User.all.second.id, "Unable to assign following user"

        photo_count_low_rate = 6
        photo_count_high_rate = 6
        photo_count = photo_count_low_rate + photo_count_high_rate

        photo_count_high_rate.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: generator.rand(1..10), latitude: generator.rand(52.2..59.7), longitude: generator.rand(12.3..17.5), track_location: "yes")
          photo.created_at = rand(0.2..0.7).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        photo_count_low_rate.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: generator.rand(1..10), latitude: generator.rand(52.2..56.7), longitude: generator.rand(12.3..17.5), track_location: "yes")
          photo.created_at = rand(0..20000).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        Photo.reindex
        User.reindex
        Sunspot.commit

        get :suggested_followable_users , {'page' => 1, 'start' => 0, 'limit' => 20, 'user_latitude' => current_user.latitude, 'user_longitude' => current_user.longitude }
        assert_response :success

        users = assigns(:users)

        assert_false users.include?(User.find(current_user.following_user_ids[0])), 'Following users should not be included in the list of suggested users to follow'
        assert_false users.include?(current_user), 'Current user should not be included in the list of suggested users to follow'
        csv = CSV.generate(:force_quotes => true) do |line|
          line <<["id", "username", "latitude", "longitude", "distance in km", "votes", "sorting_rate"]

          previous_user_rate = users.first.sorting_rate current_user.latitude, current_user.longitude
          users.each { |user|
            line << user.to_csv(current_user.latitude, current_user.longitude)
            rate = user.sorting_rate(current_user.latitude, current_user.longitude)
            assert  ( previous_user_rate >= rate ) , "wrong sorting order of users: previous rate: #{previous_user_rate} this rate: #{rate}"
            previous_user_rate = rate
          }
        end

        File.open(File.join(Rails.root, 'test', 'results', 'users', "#{Time.now.to_s}.csv"), "w"){ |file| file.write csv }

      end
    end
  end
end
