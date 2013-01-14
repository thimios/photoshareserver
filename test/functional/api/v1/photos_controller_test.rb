require 'test_helper'
include Devise::TestHelpers


module Api
  module V1

    class PhotosControllerTest < ActionController::TestCase
      include TestSunspot

      setup do
        sign_in User.first
        @generator = Random.new
      end

      test "should create photo without named location reference" do
        assert_empty Photo.find_all_by_title "photo without location", "Photo should not be there"
        post :create, { :title => "photo without location", :category_id => 1, :user_id => @generator.rand(1..2), :latitude => 52.2, :longitude => 12.3, :track_location => "yes" }
      end

      test "should create photo and named location" do
        location_reference_string = "CmRYAAAAciqGsTRX1mXRvuXSH2ErwW-jCINE1aLiwP64MCWDN5vkXvXoQGPKldMfmdGyqWSpm7BEYCgDm-iv7Kc2PF7QA7brMAwBbAcqMr5i1f4PwTpaovIZjysCEZTry8Ez30wpEhCNCXpynextCld2EBsDkRKsGhSLayuRyFsex6JA6NPh9dyupoTH3g"
        assert_empty Photo.find_all_by_title "photo with location", "Photo should not be there"
        post :create, { :title => "photo with location", :category_id => 1, :user_id => @generator.rand(1..2), :latitude => 52.2, :longitude => 12.3, :track_location => "yes", :location_reference => location_reference_string }
        assert_not_empty Photo.find_all_by_title "photo with location", "Photo should be created"
        assert_not_empty NamedLocation.find_all_by_reference location_reference_string, "Named location should be created"
        photos = Photo.find_all_by_title "photo with location"

        assert_equal(photos.first.location_reference, location_reference_string)
      end

      test "delete photo and all comments, votes, photo_reports" do
        PublicActivity.enabled= true
        PublicActivity.set_controller(@controller)
        user2 = User.all.second

        first_photo  = Photo.create(title: "first photo", category_id: 1, user_id: @generator.rand(1..2), latitude: 52.2, longitude: 12.3, track_location: "yes")
        first_photo.save

        comment = first_photo.comments.build( body: Faker::Lorem.sentence(3) )
        comment.owner = user2
        comment.save

        user2.vote_for( first_photo)

        report = PhotoReport.create(:photo_id => first_photo.id, :user_id => user2.id)
        report.save

        # until now there should be one photo, one comment, one vote and one report created
        loaded_photo = Photo.find(first_photo.id)
        assert_not_nil(loaded_photo, "Created photo not found in db")
        assert_equal(loaded_photo.comments_count, 1, "Photo should have exactly one comment")
        assert_equal(loaded_photo.plusminus, 1, "Photo should have exactly one vote")
        assert_equal(loaded_photo.photo_reports.count, 1, "Photo should have exactly one report")

        loaded_photo.destroy

        assert_true loaded_photo.destroyed?, "Photo not destroyed"
        assert_equal(loaded_photo.comments_count, 0, "Destoyed photo should have no comments")
        assert_equal(loaded_photo.plusminus, 0, "Destroyed photo should have no votes")
        assert_equal(loaded_photo.photo_reports.count, 0, "Destoyed photo should have no photo report")
        assert_equal(Comment.all.count, 0, "Destoyed photo should have no comments")
        assert_equal(Vote.all.count, 0, "Destroyed photo should have no votes")
        assert_equal(PhotoReport.all.count, 0, "Destoyed photo should have no photo report")


        activities = PublicActivity::Activity.all
        assert_equal(activities.count, 7, "There should have been 7 activities tracked")
        assert_equal(activities[0].key, "photo.create", "Activity tracking error")
        assert_equal(activities[1].key, "photo.update", "Activity tracking error")
        assert_equal(activities[2].key, "comment.create", "Activity tracking error")
        assert_equal(activities[3].key, "vote.create", "Activity tracking error")
        assert_equal(activities[4].key, "vote.destroy", "Activity tracking error")
        assert_equal(activities[5].key, "comment.destroy", "Activity tracking error")
        assert_equal(activities[6].key, "photo.destroy", "Activity tracking error")

      end

      test "test photo sorting algorithm, random distances" do
        # /api/v1/photos.json?_dc=1356628364027&auth_token=Hy4JzyV8XVxpDtt7rStj&user_latitude=37.0435203&user_longitude=22.110219000000004&page=1&start=0&limit=10&filter=%5B%7B%22property%22%3A%22category_id%22%2C%22value%22%3A%221%22%7D%5D

        photo_count_low_rate = 60
        photo_count_high_rate = 60
        photo_count = photo_count_low_rate + photo_count_high_rate

        #creating first photo
        first_photo  = Photo.create(title: "first photo", category_id: 1, user_id: @generator.rand(1..2), latitude: 52.2, longitude: 12.3, track_location: "yes")
        first_photo.save
        users = User.order('RAND()').limit(10)
        users.each {|user|
          user.vote_for (first_photo)
        }


        photo_count_high_rate.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: @generator.rand(1..2), latitude: @generator.rand(52.2..59.7), longitude: @generator.rand(12.3..17.5), track_location: "yes")
          photo.created_at = rand(0.2..0.7).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        photo_count_low_rate.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: @generator.rand(1..2), latitude: @generator.rand(52.2..56.7), longitude: @generator.rand(12.3..17.5), track_location: "yes")
          photo.created_at = rand(0..20000).hours.ago
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
        FileUtils.mkdir_p File.join(Rails.root, 'test', 'results', 'photos')
        File.open(File.join(Rails.root, 'test', 'results', 'photos', "#{Time.now.to_s}.csv"), "w"){ |file| file.write csv }
      end
    end
  end
end
