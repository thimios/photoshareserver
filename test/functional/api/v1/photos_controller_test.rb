require 'test_helper'
include Devise::TestHelpers



module Api
  module V1

    class PhotosControllerTest < ActionController::TestCase
      fixtures :categories, :users, :photos, :quotes, :photo_reports, :named_locations
      include TestSunspot

      setup do
        sign_in User.first
        @generator = Random.new
      end

      test "index bbox, should not return two photos with the same location id" do
        sw_y=55.2
        sw_x=18.3
        ne_y=58.7
        ne_x=22.5

        3.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23),
                               category_id: 1,
                               user_id: @generator.rand(1..10),
                               latitude: @generator.rand(sw_y..ne_y),
                               longitude: @generator.rand(sw_x..ne_x),
                               show_on_map: true)
          photo.created_at = rand(2..20000).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        longitude = @generator.rand(sw_x..ne_x)
        latitude = @generator.rand(sw_y..ne_y)
        named_location = NamedLocation.create( reference: Faker::Lorem.characters,
                                               google_id: Faker::Lorem.characters(40),
                                               latitude: latitude,
                                               longitude: longitude,
                                               name: Faker::Lorem.words(2),
                                               vicinity: Faker::Lorem.word)

        3.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23),
                               category_id: 1, user_id: @generator.rand(1..10),
                               latitude: latitude,
                               longitude: longitude,
                               show_on_map: true, named_location_id: named_location.id)

          photo.created_at = rand(2..20000).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        named_location = NamedLocation.create( reference: Faker::Lorem.characters,
                                               google_id: Faker::Lorem.characters(40),
                                               latitude: latitude,
                                               longitude: longitude,
                                               name: Faker::Lorem.words(2),
                                               vicinity: Faker::Lorem.word)

        3.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23),
                               category_id: 1, user_id: @generator.rand(1..10),
                               latitude: latitude,
                               longitude: longitude,
                               show_on_map: true, named_location_id: named_location.id)

          photo.created_at = rand(2..20000).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        Photo.reindex
        Sunspot.commit

        get :indexbbox, {
            :sw_y => sw_y,
            :sw_x => sw_x,
            :ne_y => ne_y,
            :ne_x => ne_x,
            :fashion => "true",
            :art => "true",
            :place => "true",
            :current_markers => ""
        }

        assert_response :success
        data = ActiveSupport::JSON.decode(response.body)

        assert_not_nil data
        assert_equal 5, data['to_add_photos'].count, "map should include only photos with unique location ids or no locations"

      end


      test "index bbox, return maximum 25 markers, when less are available" do

        photos_without_named_location_count = 3
        photos_with_named_location_count = 3
        sw_y=55.2
        sw_x=18.3
        ne_y=58.7
        ne_x=22.5

        photos_without_named_location_count.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23),
                               category_id: 1,
                               user_id: @generator.rand(1..10),
                               latitude: @generator.rand(sw_y..ne_y),
                               longitude: @generator.rand(sw_x..ne_x),
                               show_on_map: true)
          photo.created_at = rand(2..20000).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        photos_with_named_location_count.times do
          longitude = @generator.rand(sw_x..ne_x)
          latitude = @generator.rand(sw_y..ne_y)

          named_location = NamedLocation.create( reference: Faker::Lorem.characters,
                                                 google_id: Faker::Lorem.characters(40),
                                                 latitude: latitude,
                                                 longitude: longitude,
                                                 name: Faker::Lorem.words(2),
                                                 vicinity: Faker::Lorem.word)

          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23),
                               category_id: 1, user_id: @generator.rand(1..10),
                               latitude: latitude,
                               longitude: longitude,
                               show_on_map: true, named_location_id: named_location.id)

          photo.created_at = rand(2..20000).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        Photo.reindex
        Sunspot.commit

        get :indexbbox, {
            :sw_y => sw_y,
            :sw_x => sw_x,
            :ne_y => ne_y,
            :ne_x => ne_x,
            :fashion => "true",
            :art => "true",
            :place => "true",
            :current_markers => ""
        }

        assert_response :success
        data = ActiveSupport::JSON.decode(response.body)

        assert_not_nil data
        assert_equal photos_without_named_location_count + photos_with_named_location_count, data['to_add_photos'].count, "map should include all photos, if less than 10 photos are available on that area"

      end

      test "index bbox, return 25 markers, when more than 10 are available" do

        photos_without_named_location_count = 15
        photos_with_named_location_count = 15
        sw_y=55.2
        sw_x=18.3
        ne_y=58.7
        ne_x=22.5

        photos_without_named_location_count.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23),
                               category_id: 1,
                               user_id: @generator.rand(1..10),
                               latitude: @generator.rand(sw_y..ne_y),
                               longitude: @generator.rand(sw_x..ne_x),
                               show_on_map: true)
          photo.created_at = rand(2..20000).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        photos_with_named_location_count.times do
          longitude = @generator.rand(sw_x..ne_x)
          latitude = @generator.rand(sw_y..ne_y)

          named_location = NamedLocation.create( reference: Faker::Lorem.characters,
                                                 google_id: Faker::Lorem.characters(40),
                                                 latitude: latitude,
                                                 longitude: longitude,
                                                 name: Faker::Lorem.words(2),
                                                 vicinity: Faker::Lorem.word)

          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23),
                               category_id: 1, user_id: @generator.rand(1..10),
                               latitude: latitude,
                               longitude: longitude,
                               show_on_map: true, named_location_id: named_location.id)

          photo.created_at = rand(2..20000).hours.ago
          photo.save

          users = User.order('RAND()').limit(rand(0..10))
          users.each {|user|
            user.vote_for (photo)
          }
        end

        Photo.reindex
        Sunspot.commit

        get :indexbbox, {
            :sw_y => sw_y,
            :sw_x => sw_x,
            :ne_y => ne_y,
            :ne_x => ne_x,
            :fashion => "true",
            :art => "true",
            :place => "true",
            :current_markers => ""
        }

        assert_response :success
        data = ActiveSupport::JSON.decode(response.body)

        assert_not_nil data
        assert_equal 25, data['to_add_photos'].count, "map should always include maximum 10 photos"

      end

      test "index bbox" do
        #y latitude
        #x longitude
        Photo.reindex
        Sunspot.commit

        sw_y=52.13493973799441
        sw_x=12.236575518896416
        ne_y=52.77962430368643
        ne_x=12.764041339208916

        get :indexbbox, {
            :sw_y => sw_y,
            :sw_x => sw_x,
            :ne_y => ne_y,
            :ne_x => ne_x,
            :fashion => "true",
            :art => "true",
            :place => "true",
            :current_markers => ""
        }

        assert_response :success
        data = ActiveSupport::JSON.decode(response.body)

        assert_not_nil data
        assert_equal 1, data['to_add_photos'].count, "should return only one photo of the fixture for each location and only photos with show_on_map true"


        # test with two markers already on the map
        get :indexbbox, {
            :sw_y => sw_y,
            :sw_x => sw_x,
            :ne_y => ne_y,
            :ne_x => ne_x,
            :fashion => "true",
            :art => "true",
            :place => "true",
            :current_markers => "1"
        }

        assert_response :success
        data = ActiveSupport::JSON.decode(response.body)

        assert_not_nil data
        assert_equal 1, data['to_add_photos'].count, "should return one more photo"

        # test with two extra markers that should be removed from the map
        get :indexbbox, {
            :sw_y => sw_y,
            :sw_x => sw_x,
            :ne_y => ne_y,
            :ne_x => ne_x,
            :fashion => "true",
            :art => "true",
            :place => "true",
            :current_markers => "2,3,45,46"
        }

        assert_response :success
        data = ActiveSupport::JSON.decode(response.body)

        assert_not_nil data
        assert_equal 0, data['to_add_photos'].count, "should return no more photos of the fixture"
        assert_equal 3, data['to_remove_ids'].count
      end

      test "should create photo without named location reference" do
        count = NamedLocation.count
        assert_empty Photo.find_all_by_title "photo without location", "Photo should not be there"
        post :create, { :title => "photo without location", :category_id => 1, :user_id => @generator.rand(1..2), :latitude => 52.2, :longitude => 12.3, show_on_map: true}
        assert_response :success

        assert_equal count, NamedLocation.count

      end

      test "should create photo and named location" do
        location_reference_string = "CoQBewAAACPvF7X9k8oESf-dqXAYvf1RbJu51SROVwrEjl8RGl2N1iftFWtUCvsOqRXzbLgcfN1DOcld-AwaVMa-aU5ubmA3QYV0RUb7MtAtUML3qNFOM0PuVTvVR2NC9yOumVui8v5tfVkZYzKj0fvLlwlYHr01RkWLMAEc_2M1ww0IhzpcEhCwLxG5ZDZ7akhO2As18G8GGhQta0Ac3s-DZvGVjBxeL_KDzgt0eg"
        location_google_id = "72537495dd878b6bd2feb0104e263e730e1e63a0"
        location_name = "Hasenheide Volkspark"
        location_vicinity = "Berlin"
        assert_empty Photo.find_all_by_title "photo with location", "Photo should not be there"
        post :create, { :title => "photo with location", :category_id => 1, :user_id => @generator.rand(1..2), :latitude => 52.2, :longitude => 12.3, show_on_map: true, :location_reference => location_reference_string, :location_google_id => location_google_id, :location_name => location_name, :location_vicinity => location_vicinity }
        assert_not_empty Photo.find_all_by_title "photo with location", "Photo should be created"
        assert_not_empty NamedLocation.find_all_by_reference location_reference_string, "Named location should be created"
        photos = Photo.find_all_by_title "photo with location"

        assert_equal(location_reference_string, photos.first.location_reference )
      end

      test "delete photo and all comments, votes, photo_reports" do
        PublicActivity.enabled= true
        PublicActivity.set_controller(@controller)
        user2 = User.all.second

        first_photo  = Photo.create(title: "first photo", category_id: 1, user_id: @generator.rand(1..2), latitude: 52.2, longitude: 12.3, show_on_map: true)
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
        assert_equal(1, loaded_photo.comments_count, "Photo should have exactly one comment")
        assert_equal(1, loaded_photo.plusminus, "Photo should have exactly one vote")
        assert_equal(1, loaded_photo.photo_reports.count, "Photo should have exactly one report")

        loaded_photo.destroy

        assert_true loaded_photo.destroyed?, "Photo not destroyed"
        assert_equal(0, (Comment.find_all_by_commentable_id loaded_photo.id).count, "Destoyed photo should have no comments")
        assert_equal(0, loaded_photo.plusminus, "Destroyed photo should have no votes")
        assert_equal(0, loaded_photo.photo_reports.count, "Destoyed photo should have no photo report")


        activities = PublicActivity::Activity.all
        assert_equal(activities.count, 0, "all activities should be deleted")
        #assert_equal(activities[0].key, "photo.create", "Activity tracking error")
        #assert_equal(activities[1].key, "photo.update", "Activity tracking error")
        #assert_equal(activities[2].key, "comment.create", "Activity tracking error")
        #assert_equal(activities[3].key, "vote.create", "Activity tracking error")
        #assert_equal(activities[4].key, "vote.destroy", "Activity tracking error")
        #assert_equal(activities[5].key, "comment.destroy", "Activity tracking error")
        #assert_equal(activities[6].key, "photo.destroy", "Activity tracking error")

      end

      test "test photo sorting algorithm, random distances" do
        # /api/v1/photos.json?_dc=1356628364027&auth_token=Hy4JzyV8XVxpDtt7rStj&user_latitude=37.0435203&user_longitude=22.110219000000004&page=1&start=0&limit=10&filter=%5B%7B%22property%22%3A%22category_id%22%2C%22value%22%3A%221%22%7D%5D

        photo_count = 100

        #creating first photo
        first_photo  = Photo.create(title: "first photo", category_id: 1, user_id: @generator.rand(1..2), latitude: 51.2, longitude: 10.3, show_on_map: true)
        first_photo.save
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
        get :index , {'category_id' => 1, 'page' => 1, 'start' => 0, 'limit' => photo_count, 'user_latitude' => first_photo.latitude, 'user_longitude' => first_photo.longitude }
        assert_response :success

        photos = assigns(:photos)

        csv = CSV.generate(:force_quotes => true) do |line|
          line <<["id", "title", "latitude", "longitude", "distance in km",  "time in millis", "votes", "created_at", "sorting_rate"]

          previous_photo_rate = photos.first.sorting_rate first_photo.latitude, first_photo.longitude, nil,nil
          photos.each { |photo|
            line << photo.to_csv(first_photo.latitude, first_photo.longitude, nil, nil)
            rate = photo.sorting_rate(first_photo.latitude, first_photo.longitude, nil, nil)
            assert  ( previous_photo_rate > rate ) , "wrong sorting order of photos when sliders in the middle: previous rate: #{previous_photo_rate} this rate: #{rate}"
            previous_photo_rate = rate
          }
        end
        FileUtils.mkdir_p File.join(Rails.root, 'test', 'results', 'photos')
        File.open(File.join(Rails.root, 'test', 'results', 'photos', "#{Time.now.to_s}.sliders.in.the.middle.csv"), "w"){ |file| file.write csv }

        # Using sliders in the far left, recent, nearby, passing  params[:time_factor]=0 params[:distance_factor]=0
        params_time_factor = "0"
        params_distance_factor = "0"
        get :index , {'time_factor' => params_time_factor, 'distance_factor' => params_distance_factor, 'category_id' => 1, 'page' => 1, 'start' => 0, 'limit' => photo_count, 'user_latitude' => first_photo.latitude, 'user_longitude' => first_photo.longitude }
        assert_response :success

        photos = assigns(:photos)

        csv = CSV.generate(:force_quotes => true) do |line|
          line <<["id", "title", "latitude", "longitude", "distance in km",  "time in millis", "votes", "created_at", "sorting_rate"]

          previous_photo_rate = photos.first.sorting_rate first_photo.latitude, first_photo.longitude, params_time_factor, params_distance_factor
          photos.each { |photo|
            line << photo.to_csv(first_photo.latitude, first_photo.longitude, params_time_factor, params_distance_factor)
            rate = photo.sorting_rate(first_photo.latitude, first_photo.longitude, params_time_factor, params_distance_factor)
            assert  ( previous_photo_rate > rate ) , "wrong sorting order of photos when sliders in the left: previous rate: #{previous_photo_rate} this rate: #{rate}"
            previous_photo_rate = rate
          }
        end
        FileUtils.mkdir_p File.join(Rails.root, 'test', 'results', 'photos')
        File.open(File.join(Rails.root, 'test', 'results', 'photos', "#{Time.now.to_s}.sliders.in.the.left.csv"), "w"){ |file| file.write csv }
      end

      test "get user feed, following one user with no photos" do
        Photo.reindex
        Sunspot.commit

        #first user is logged in user, following second user
        User.first.follow(User.find(10))

        get :index , {'feed' => true, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => @generator.rand(52.2..59.7), 'user_longitude' => @generator.rand(12.3..17.5) }
        assert_response :success

        photos = assigns(:photos)

        assert_equal(0, photos.count, "Feed should include no photos")

      end

      test "get user feed, following one user with two photos" do
        Photo.reindex
        Sunspot.commit

        #first user is logged in user, following second user, who created two photos
        User.first.follow(User.find(2))

        get :index , {'feed' => true, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => @generator.rand(52.2..59.7), 'user_longitude' => @generator.rand(12.3..17.5) }
        assert_response :success
        photos = assigns(:photos)
        assert_equal(Photo.where('user_id not in (?)', 2).count, photos.count, "Feed should include photos belonging to second user")
      end

      test "get user feed, following one user with two photos and one location with two photos" do
        Photo.reindex
        Sunspot.commit

        first_location = NamedLocation.first

        #first user is logged in user, following second user, who created two photos
        User.first.follow(User.find(2))

        # all photos of first location actually belong to the current user, they should not be returned in the feed
        User.first.follow(first_location)

        get :index , {'feed' => true, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => @generator.rand(52.2..59.7), 'user_longitude' => @generator.rand(12.3..17.5) }
        assert_response :success
        photos = assigns(:photos)
        assert_equal(Photo.where('(user_id in (?) or named_location_id in (?)) and user_id not in (?)', 2, first_location.id, 1).count, photos.count, "Feed should include photos of second user and first location")
      end

      test "feed should not include own photos from followed location" do
        Photo.reindex
        Sunspot.commit
        User.first.follow(NamedLocation.first)
        User.first.follow(NamedLocation.find(2))
        User.first.follow(User.find(10))
        get :index , {'feed' => true, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => @generator.rand(52.2..59.7), 'user_longitude' => @generator.rand(12.3..17.5) }
        assert_response :success
        photos = assigns(:photos)
        assert_equal(Photo.where('user_id not in (?)', User.first.id).count, photos.count, "Feed should include just photos that do not belong to the current user")
      end

      test "get user feed, following one user with two photos and one location with two photos, one photo overlapping" do
        first_location = NamedLocation.first

        Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: 2, latitude: @generator.rand(52.2..59.7), longitude: @generator.rand(12.3..17.5), show_on_map: true, named_location_id: first_location.id)
        Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: 3, latitude: @generator.rand(52.2..59.7), longitude: @generator.rand(12.3..17.5), show_on_map: true, named_location_id: first_location.id)

        #and some unrelated
        2.times do
          photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: 4, latitude: @generator.rand(52.2..59.7), longitude: @generator.rand(12.3..17.5), show_on_map: true)
        end

        Photo.reindex
        Sunspot.commit

        #first user is logged in user, following second user, who created two photos
        User.first.follow(User.find(2))
        User.first.follow(first_location)

        get :index , {'feed' => true, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => @generator.rand(52.2..59.7), 'user_longitude' => @generator.rand(12.3..17.5) }
        assert_response :success
        photos = assigns(:photos)
        assert_equal(Photo.where('(user_id in (?) or named_location_id in (?)) and user_id not in (?)', 2, first_location.id, 1).count, photos.count, "Feed should include 4 photos")
      end
    end
  end
end
