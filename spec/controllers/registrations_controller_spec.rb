require 'rails_helper'
include Devise::TestHelpers
include Api::V1

describe Api::V1::RegistrationsController, :type => :controller do
  login_user

  Sunspot.remove_all

  it "should have a current_user" do
    expect(subject.current_user).to_not be_nil
  end

  describe "GET index" do
    context "users following the current_user" do
      it "returns users following the current user" do
        following_users = create_list :user, 3
        create_list :user, 2
        following_users.each { |following_user|
          following_user.follow current_user
        }
        get :index , {'following_the_current_user' => 'true' }
        expect(response).to be_success
        users = assigns(:users)
        expect(users.count).to eq 3
      end
    end

    context "users following a specific user" do
      it "returns users following the user" do
        user = create :user
        following_users = create_list :user, 3
        create_list :user, 2
        following_users.each { |following_user|
          following_user.follow user
        }
        get :index , {'following_the_user_id' => user.id }
        expect(response).to be_success
        users = assigns(:users)
        expect(users.count).to eq 3
      end
    end

    context "get users followed by current user" do
      it "should return users followed" do
        followed_users = create_list :user, 3
        followed_users.each {|followed_user|
          current_user.follow followed_user
        }
        #create some irrelevant users
        create_list :user, 2
        get :index , {'followed_by_current_user' => 'true' }
        expect(response).to be_success
        users = assigns(:users)
        expect(users.count).to eq 3
      end
    end

    context "get users followed by a specific user" do
      it "should return users followed" do
        user = create :user
        followed_users = create_list :user, 3
        followed_users.each {|followed_user|
          user.follow followed_user
        }
        #create some irrelevant users
        create_list :user, 2

        get :index , {'followed_by_user_id' => user.id }

        expect(response).to be_success
        users = assigns(:users)
        expect(users.count).to eq 3
      end
    end
  end

  describe "POST #create" do
    context "without errors" do
      it "should register a new user" do
        email = "thimios.laptop@gmail.com"
        post 'create' , { :format => 'json', :registration => {:username => "Thimioslaptop", :email =>email, :password =>"[FILTERED]", :password_confirmation =>"[FILTERED]", :gender =>"male", :birth_date =>"1994-10-27T00:00:00", :thumb_size_url =>"", :id =>"ext-record-165"} }
        data = ActiveSupport::JSON.decode(response.body)
        expect(response).to be_success
        expect(data).to_not be_nil
        expect(data["email"]).to eq email
        expect(data["auth_token"]).to_not be_nil
      end
    end

    context "with wrong password confirmation" do
      it "should not register the new user and return error" do
        email = "thimios.laptop@gmail.com"
        post 'create' , { :format => 'json', :registration => {:username => "Thimioslaptop", :email =>email, :password =>"[FILTERED]", :password_confirmation =>"skata", :gender =>"male", :birth_date =>"1994-10-27T00:00:00", :thumb_size_url =>"", :id =>"ext-record-165"} }
        data = ActiveSupport::JSON.decode(response.body)

        expect(response).to have_http_status(422)
        expect(data['errors']['password'][0]).to eq "doesn't match confirmation"
      end
    end

    context "with already existing email" do
      it "should not register the new user and return error" do
        email = User.first.email
        post 'create' , { :format => 'json', :registration => {:username => "Thimioslaptop", :email =>email, :password =>"skata", :password_confirmation =>"skata", :gender =>"male", :birth_date =>"1994-10-27T00:00:00", :thumb_size_url =>"", :id =>"ext-record-165"} }
        data = ActiveSupport::JSON.decode(response.body)

        expect(response).to have_http_status(422)
        expect(data['errors']['email'][0]).to eq "has already been taken"
      end
    end
  end

  describe "GET #suggested_followable_users" do
    it "should suggest users with descending rate" do
      generator = Random.new
      5.times do
        create :user, latitude: generator.rand(52.2..59.7), longitude: generator.rand(12.3..17.5)
      end
      current_user.follow( create(:user))
      photo_count_low_rate = 5
      photo_count_high_rate = 5

      photo_count_high_rate.times do
        photo = create :photo, :with_random_votes, latitude: generator.rand(52.2..59.7), longitude: generator.rand(12.3..17.5), show_on_map: true
        photo.created_at = rand(0.2..0.7).hours.ago
        photo.save
      end
      photo_count_low_rate.times do
        photo = create :photo, :with_random_votes, latitude: generator.rand(52.2..56.7), longitude: generator.rand(12.3..17.5), show_on_map: true
        photo.created_at = rand(0..20000).hours.ago
        photo.save
      end
      Photo.reindex
      User.reindex
      get :suggested_followable_users , {'page' => 1, 'start' => 0, 'limit' => 20, 'user_latitude' => current_user.latitude, 'user_longitude' => current_user.longitude }
      expect(response).to be_success
      users = assigns(:users)
      expect(users).to_not include(User.find(current_user.following_user_ids[0]))
      expect(users).to_not include(current_user)
      previous_user_rate = users.first.sorting_rate current_user.latitude, current_user.longitude
      users.each { |user|
        rate = user.sorting_rate(current_user.latitude, current_user.longitude)
        expect(previous_user_rate).to be >= rate
        previous_user_rate = rate
      }
    end
  end
end

