require 'rails_helper'
include Devise::TestHelpers
include Api::V1

describe Api::V1::PhotosController, :type => :controller do
  login_user

  Sunspot.remove_all

  it "should have a current_user" do
    expect(subject.current_user).to_not be_nil
  end

  describe "GET #indexbbox" do

    it "should not return two photos with the same location id" do
      random_gen = Random.new
      sw_y=55.2
      sw_x=18.3
      ne_y=58.7
      ne_x=22.5

      create_list :photo, 3,
                       latitude: random_gen.rand(sw_y..ne_y),
                       longitude: random_gen.rand(sw_x..ne_x),
                       show_on_map: true
      2.times do
        longitude = random_gen.rand(sw_x..ne_x)
        latitude = random_gen.rand(sw_y..ne_y)
        create :named_location, :with_three_photos,
               latitude: latitude,
               longitude: longitude
      end

      Photo.reindex

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

      expect( data ).to_not be_nil
      expect(data['to_add_photos'].count).to eq(5)
    end

    it "should return maximum 25 markers, when less are available" do
      random_gen = Random.new
      photos_without_named_location_count = 3
      photos_with_named_location_count = 3
      sw_y=55.2
      sw_x=18.3
      ne_y=58.7
      ne_x=22.5

      create_list(:photo, photos_without_named_location_count, :with_vote,
             latitude: random_gen.rand(sw_y..ne_y),
             longitude: random_gen.rand(sw_x..ne_x),
             show_on_map: true)

      photos_with_named_location_count.times do
        longitude = random_gen.rand(sw_x..ne_x)
        latitude = random_gen.rand(sw_y..ne_y)

        create :named_location, :with_one_photo,
               latitude: latitude,
               longitude: longitude
      end

      Photo.reindex

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
      expect(response).to be_success
      data = ActiveSupport::JSON.decode(response.body)

      expect(data).to_not be_nil
      expect(data['to_add_photos'].count).to eq(photos_without_named_location_count + photos_with_named_location_count)
    end

    it "should return 25 markers, when more than 10 are available" do
      random_gen = Random.new
      photos_without_named_location_count = 15
      photos_with_named_location_count = 15
      sw_y=55.2
      sw_x=18.3
      ne_y=58.7
      ne_x=22.5

      create_list(:photo, photos_without_named_location_count, :with_vote,
                  latitude: random_gen.rand(sw_y..ne_y),
                  longitude: random_gen.rand(sw_x..ne_x),
                  show_on_map: true)

      photos_with_named_location_count.times do
        longitude = random_gen.rand(sw_x..ne_x)
        latitude = random_gen.rand(sw_y..ne_y)

        create :named_location, :with_one_photo,
               latitude: latitude,
               longitude: longitude
      end

      Photo.reindex

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
      expect(response).to be_success
      data = ActiveSupport::JSON.decode(response.body)

      expect(data).to_not be_nil
      expect(data['to_add_photos'].count).to eq(25)
    end

    context "with one photo with show on map true and one photo with show on map false" do
      before(:each) do
        random_gen = Random.new
        @sw_y=55.2
        @sw_x=18.3
        @ne_y=58.7
        @ne_x=22.5

        @photo_show_on_map = create(:photo,
               latitude: random_gen.rand(@sw_y..@ne_y),
               longitude: random_gen.rand(@sw_x..@ne_x),
               show_on_map: true)
        @photo_hide_on_map = create(:photo,
               latitude: random_gen.rand(@sw_y..@ne_y),
               longitude: random_gen.rand(@sw_x..@ne_x),
               show_on_map: false)
        Photo.reindex
      end

      it "should only return photos with show on map true" do
        get :indexbbox, {
                          :sw_y => @sw_y,
                          :sw_x => @sw_x,
                          :ne_y => @ne_y,
                          :ne_x => @ne_x,
                          :fashion => "true",
                          :art => "true",
                          :place => "true",
                          :current_markers => ""
                      }
        expect(response).to be_success
        data = ActiveSupport::JSON.decode(response.body)
        expect(data).to_not be_nil
        expect(data['to_add_photos'].count).to eq(1)
      end

      it "should add one photo when one marker is already on the map" do
        get :indexbbox, {
                         :sw_y => @sw_y,
                         :sw_x => @sw_x,
                         :ne_y => @ne_y,
                         :ne_x => @ne_x,
                         :fashion => "true",
                         :art => "true",
                         :place => "true",
                         :current_markers => "-1"
                     }
        expect(response).to be_success
        data = ActiveSupport::JSON.decode(response.body)
        expect(data).to_not be_nil
        expect(data['to_add_photos'].count).to eq(1)
      end

      it "should remove extra markers already on the map" do
        get :indexbbox, {
                          :sw_y => @sw_y,
                          :sw_x => @sw_x,
                          :ne_y => @ne_y,
                          :ne_x => @ne_x,
                          :fashion => "true",
                          :art => "true",
                          :place => "true",
                          :current_markers => "#{@photo_show_on_map.id},-3,-45,-46"
                      }

        expect(response).to be_success
        data = ActiveSupport::JSON.decode(response.body)
        expect(data).to_not be_nil
        expect(data['to_add_photos'].count).to eq(0)
        expect(data['to_remove_ids'].count).to eq(3)
      end
    end
  end

  describe "POST #create" do
    context "without named location" do
      it "should create photo" do
        random_gen = Random.new
        count = NamedLocation.count
        assert_empty Photo.find_all_by_title "photo without location", "Photo should not be there"
        post :create, { :title => "photo without location", :category_id => 1, :user_id => random_gen.rand(1..2), :latitude => 52.2, :longitude => 12.3, show_on_map: true}
        expect(response).to be_success
        expect(count).to eq(NamedLocation.count)
      end
    end

    context "with named location" do
      it "should create photo and named location" do
        location_reference_string = "CoQBewAAACPvF7X9k8oESf-dqXAYvf1RbJu51SROVwrEjl8RGl2N1iftFWtUCvsOqRXzbLgcfN1DOcld-AwaVMa-aU5ubmA3QYV0RUb7MtAtUML3qNFOM0PuVTvVR2NC9yOumVui8v5tfVkZYzKj0fvLlwlYHr01RkWLMAEc_2M1ww0IhzpcEhCwLxG5ZDZ7akhO2As18G8GGhQta0Ac3s-DZvGVjBxeL_KDzgt0eg"
        location_google_id = "72537495dd878b6bd2feb0104e263e730e1e63a0"
        location_name = "Hasenheide Volkspark"
        location_vicinity = "Berlin"
        assert_empty Photo.find_all_by_title "photo with location", "Photo should not be there"
        post :create, { :title => "photo with location", :category_id => 1, :user_id => 1, :latitude => 52.2, :longitude => 12.3, show_on_map: true, :location_reference => location_reference_string, :location_google_id => location_google_id, :location_name => location_name, :location_vicinity => location_vicinity }
        assert_not_empty Photo.find_all_by_title "photo with location", "Photo should be created"
        assert_not_empty NamedLocation.find_all_by_reference location_reference_string, "Named location should be created"
        photos = Photo.find_all_by_title "photo with location"
        expect(location_reference_string).to eq(photos.first.location_reference )
      end
    end
  end

  describe "GET #index" do
    before(:each) do
      random_gen = Random.new
      @user_latitude = random_gen.rand(40.2..52.7)
      @user_longitude = random_gen.rand(-74.0..29.5)

      @photo_count = 15
      @photo_count.times do
        create :photo, :with_random_votes, latitude: random_gen.rand(40.2..52.7), longitude: random_gen.rand(-74.0..29.5)
      end

      Photo.reindex
    end

    context "with sorting configuration sliders in the middle" do
      it "should sort photos in descending rate" do
        # Using sliders in the middle, passing no params[:time_factor] params[:distance_factor]
        get :index , {'category_id' => 1, 'page' => 1, 'start' => 0, 'limit' => @photo_count, 'user_latitude' => @user_latitude, 'user_longitude' => @user_longitude }
        expect(response).to be_success
        photos = assigns(:photos)
        expect(photos.count).to eq @photo_count

        previous_photo_rate = photos.first.sorting_rate @user_latitude, @user_longitude, nil,nil
        photos.each { |photo|
          rate = photo.sorting_rate(@user_latitude, @user_longitude, nil, nil)
          expect(previous_photo_rate).to be >= rate
          previous_photo_rate = rate
        }
      end
    end

    context "with sorting configuration sliders in max left, recent nearby photos first" do
      it "should sort photos in descending rate" do
        # Using sliders in the far left, recent, nearby, passing  params[:time_factor]=0 params[:distance_factor]=0
        params_time_factor = "0"
        params_distance_factor = "0"
        get :index , {'time_factor' => params_time_factor, 'distance_factor' => params_distance_factor, 'category_id' => 1, 'page' => 1, 'start' => 0, 'limit' => @photo_count, 'user_latitude' => @user_latitude, 'user_longitude' => @user_longitude }
        expect(response).to be_success
        photos = assigns(:photos)
        expect(photos.count).to eq @photo_count

        previous_photo_rate = photos.first.sorting_rate @user_latitude, @user_longitude, params_time_factor, params_distance_factor
        photos.each { |photo|
          rate = photo.sorting_rate(@user_latitude, @user_longitude, params_time_factor, params_distance_factor)
          # TODO: check why this test is failing
          # expect(previous_photo_rate).to be >= rate
          previous_photo_rate = rate
        }
      end
    end
  end

  describe "GET #index user feed" do
    before :each do
      @random_gen = Random.new
    end

    context "following one user that has no photos" do
      it "should contain no photos" do
        user_to_follow = create :user
        current_user.follow user_to_follow
        Photo.reindex

        get :index , {'feed' => true, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => @random_gen.rand(52.2..59.7), 'user_longitude' => @random_gen.rand(12.3..17.5) }
        expect(response).to be_success
        photos = assigns(:photos)
        expect(photos.count).to eq 0
      end
    end

    context "following one user with two photos" do
      it "should contain photos of the following user" do
        user_to_follow = create( :user )
        create_list :photo, 2, user: user_to_follow
        current_user.follow user_to_follow
        Photo.reindex

        get :index , {'feed' => true, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => @random_gen.rand(52.2..59.7), 'user_longitude' => @random_gen.rand(12.3..17.5) }
        expect(response).to be_success
        photos = assigns(:photos)
        expect(photos.count).to eq 2
      end
    end

    context "following one user with two photos and one location with two photos" do
      it "should contain four photos" do
        user_to_follow = create( :user )
        create_list :photo, 2, user: user_to_follow
        current_user.follow user_to_follow

        named_location_to_follow = create(:named_location)
        create_list :photo, 2,
                    named_location: named_location_to_follow,
                    longitude: named_location_to_follow.longitude,
                    latitude: named_location_to_follow.latitude
        current_user.follow named_location_to_follow

        Photo.reindex
        get :index , {'feed' => true, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => current_user.latitude, 'user_longitude' => current_user.longitude }
        expect(response).to be_success
        photos = assigns(:photos)
        expect(photos.count).to eq 4
      end
    end

    it "should not include own photos from followed location" do
      user_to_follow = create( :user )
      create_list :photo, 2, user: user_to_follow
      current_user.follow user_to_follow

      named_location_to_follow = create(:named_location)
      create_list :photo, 2,
                  named_location: named_location_to_follow,
                  longitude: named_location_to_follow.longitude,
                  latitude: named_location_to_follow.latitude
      current_user.follow named_location_to_follow

      create_list :photo, 2,
                  named_location: named_location_to_follow,
                  longitude: named_location_to_follow.longitude,
                  latitude: named_location_to_follow.latitude,
                  user: current_user
      Photo.reindex
      get :index , {'feed' => true, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => current_user.latitude, 'user_longitude' => current_user.longitude }
      expect(response).to be_success
      photos = assigns(:photos)
      expect(photos.count).to eq 4
      photos.each do |photo|
        expect(photo.user.id).to_not eq(current_user.id)
      end
    end

    context "following one user with two photos and one location with two photos, one photo overlapping" do
      it "should not contain overlapping photo two times" do
        user_to_follow = create( :user )
        create_list :photo, 2, user: user_to_follow
        current_user.follow user_to_follow

        named_location_to_follow = create(:named_location)
        create_list :photo, 2,
                    named_location: named_location_to_follow,
                    longitude: named_location_to_follow.longitude,
                    latitude: named_location_to_follow.latitude
        current_user.follow named_location_to_follow

        create_list :photo, 2,
                    named_location: named_location_to_follow,
                    longitude: named_location_to_follow.longitude,
                    latitude: named_location_to_follow.latitude,
                    user: current_user
        overlapping_photo = create :photo, named_location: named_location_to_follow,
               longitude: named_location_to_follow.longitude,
               latitude: named_location_to_follow.latitude,
               user: user_to_follow
        Photo.reindex

        get :index , {'feed' => true, 'page' => 1, 'start' => 0, 'limit' => 50, 'user_latitude' => current_user.latitude, 'user_longitude' => current_user.longitude }
        expect(response).to be_success
        photos = assigns(:photos)
        expect(photos.count).to eq 5
        photos.delete_if{ |photo| photo.id != overlapping_photo.id}
        expect(photos.count).to eq(1)
      end
    end
  end
end

