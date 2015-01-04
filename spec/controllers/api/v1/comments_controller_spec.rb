require 'rails_helper'
include Devise::TestHelpers
module Api
  module V1
    describe CommentsController, :type => :controller do
      login_user

      Sunspot.remove_all

      it "should have a current_user" do
        expect(subject.current_user).to_not be_nil
      end

      describe "GET #index" do
        it "returns the comments of a specific photo" do
          photo = create :photo, :with_one_comment
          get :index, { photo_id: photo.id}
          assert_response :success
          data = ActiveSupport::JSON.decode(response.body)
          expect( data ).to_not be_nil
          expect(data['total_count']).to eq(1)
        end
      end
    end
  end
end

