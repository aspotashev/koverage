require 'test_helper'

class VotingControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get update_module" do
    get :update_module
    assert_response :success
  end

  test "should get update_package" do
    get :update_package
    assert_response :success
  end

  test "should get update_file" do
    get :update_file
    assert_response :success
  end

  test "should get my" do
    get :my
    assert_response :success
  end

end
