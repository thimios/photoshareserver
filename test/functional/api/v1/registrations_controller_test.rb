require 'test_helper'
include Devise::TestHelpers


module Api
  module V1

    class RegistrationsControllerTest < ActionController::TestCase
      fixtures :categories, :users, :quotes, :photo_reports, :named_locations
      include TestSunspot

      setup do

        @request.env["devise.mapping"] = Devise.mappings[:user]
      end

      test "register new user" do
        # tell Devise which mapping should be used before a request. This is necessary because Devise gets this information from router, but since functional tests do not pass through the router, it needs to be told explicitly.
        email = "thimios.laptop@gmail.com"
        post 'create' , { :format => 'json', :registration => {:username => "Thimioslaptop", :email =>email, :password =>"[FILTERED]", :password_confirmation =>"[FILTERED]", :gender =>"male", :birth_date =>"1994-10-27T00:00:00", :thumb_size_url =>"", :id =>"ext-record-165"} }
        data = ActiveSupport::JSON.decode(response.body)

        assert_response :success
        assert_not_nil data
        assert_equal email, data["email"]
        assert_not_nil data["auth_token"], "Auth token should be set directly after registration, so that user is considered logged in"
      end

      test "register user with wrong password confirmation should fail with error message" do
        # tell Devise which mapping should be used before a request. This is necessary because Devise gets this information from router, but since functional tests do not pass through the router, it needs to be told explicitly.
        email = "thimios.laptop@gmail.com"
        post 'create' , { :format => 'json', :registration => {:username => "Thimioslaptop", :email =>email, :password =>"[FILTERED]", :password_confirmation =>"skata", :gender =>"male", :birth_date =>"1994-10-27T00:00:00", :thumb_size_url =>"", :id =>"ext-record-165"} }
        data = ActiveSupport::JSON.decode(response.body)

        assert_response 422
        assert_equal "doesn't match confirmation", data['errors']['password'][0]
      end

      test "register user with existing email should fail with error message" do
        # tell Devise which mapping should be used before a request. This is necessary because Devise gets this information from router, but since functional tests do not pass through the router, it needs to be told explicitly.
        email = User.first.email
        post 'create' , { :format => 'json', :registration => {:username => "Thimioslaptop", :email =>email, :password =>"skata", :password_confirmation =>"skata", :gender =>"male", :birth_date =>"1994-10-27T00:00:00", :thumb_size_url =>"", :id =>"ext-record-165"} }
        data = ActiveSupport::JSON.decode(response.body)

        assert_response 422
        assert_equal "has already been taken", data['errors']['email'][0]
      end

      test "test suggested users" do
        sign_in User.first
        PublicActivity.enabled= false

        # /api/v1/users/suggested.json?_dc=1356628364027&auth_token=Hy4JzyV8XVxpDtt7rStj&user_latitude=37.0435203&user_longitude=22.110219000000004&page=1&start=0&limit=20
        generator = Random.new
        User.all.each do |user|
          user.update_attribute :latitude, generator.rand(52.2..59.7)
          user.update_attribute :longitude, generator.rand(12.3..17.5)
        end
        User.first.follow User.all.second
        current_user = User.first

        assert_equal User.first.following_user_ids[0], User.all.second.id, "Unable to assign following user"

        photo_count_low_rate = 60
        photo_count_high_rate = 60
        photo_count = photo_count_low_rate + photo_count_high_rate

        photo_count_high_rate.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: 1, latitude: generator.rand(52.2..59.7), longitude: generator.rand(12.3..17.5), show_on_map: true)
          photo.created_at = rand(0.2..0.7).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        photo_count_low_rate.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: 1, latitude: generator.rand(52.2..56.7), longitude: generator.rand(12.3..17.5), show_on_map: true)
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
        FileUtils.mkdir_p File.join(Rails.root, 'test', 'results', 'users')
        File.open(File.join(Rails.root, 'test', 'results', 'users', "#{Time.now.to_s}.csv"), "w"){ |file| file.write csv }

      end
    end
  end
end
