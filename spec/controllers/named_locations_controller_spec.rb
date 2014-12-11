require 'rails_helper'
include Devise::TestHelpers
include Api::V1

describe NamedLocationsController, :type => :controller do
  login_user

  it "should have a current_user" do
    expect(subject.current_user).to_not be_nil
  end

  describe "GET #suggested_followable_locations" do

    it "responds successfully" do
      get :suggested_followable_locations,
          {
              'page' => 1, 'start' => 0,
              'limit' => 20, 'user_latitude' => current_user.latitude,
              'user_longitude' => current_user.longitude
          }
      expect(response).to be_success
    end

    context "one named location nearby that has no photos" do

      it "responds with one location" do
        create :named_location, latitude: current_user.latitude, longitude: current_user.longitude
        NamedLocation.reindex
        get :suggested_followable_locations ,
            {
                'page' => 1, 'start' => 0,
                'limit' => 20, 'user_latitude' => current_user.latitude,
                'user_longitude' => current_user.longitude
            }
        data = ActiveSupport::JSON.decode(response.body)
        expect(data).to_not be_nil
        expect(data['records'].count).to be(0)
      end
    end

    context "one named location that has one photo nearby" do

      it "responds with one location" do
        create :named_location, :with_one_photo, latitude: current_user.latitude, longitude: current_user.longitude
        NamedLocation.reindex
        get :suggested_followable_locations ,
            {
                'page' => 1, 'start' => 0,
                'limit' => 20, 'user_latitude' => current_user.latitude,
                'user_longitude' => current_user.longitude
            }
        data = ActiveSupport::JSON.decode(response.body)
        expect(data).to_not be_nil
        expect(data['records'].count).to be(1)
      end
    end
  end
end

