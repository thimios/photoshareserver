#require 'test_helper'
#
#class NamedLocationsControllerTest < ActionController::TestCase
#  setup do
#    @named_location = named_locations(:one)
#  end
#
#  test "should get index" do
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:named_locations)
#  end
#
#  test "should get new" do
#    get :new
#    assert_response :success
#  end
#
#  test "should create named_location" do
#    assert_difference('NamedLocation.count') do
#      post :create, named_location: { reference: @named_location.reference }
#    end
#
#    assert_redirected_to named_location_path(assigns(:named_location))
#  end
#
#  test "should show named_location" do
#    get :show, id: @named_location
#    assert_response :success
#  end
#
#  test "should get edit" do
#    get :edit, id: @named_location
#    assert_response :success
#  end
#
#  test "should update named_location" do
#    put :update, id: @named_location, named_location: { reference: @named_location.reference }
#    assert_redirected_to named_location_path(assigns(:named_location))
#  end
#
#  test "should destroy named_location" do
#    assert_difference('NamedLocation.count', -1) do
#      delete :destroy, id: @named_location
#    end
#
#    assert_redirected_to named_locations_path
#  end
#end
