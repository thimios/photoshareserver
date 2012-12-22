require 'test_helper'
include Devise::TestHelpers

class PhotosControllerTest < ActionController::TestCase
  setup do
    sign_in User.first
    @photo = photos(:one)
  end

  test "should get index" do


    get :index
    assert_response :success
    assert_not_nil assigns(:photos)
  end


end
