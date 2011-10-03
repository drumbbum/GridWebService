require 'test_helper'

class ServicesControllerTest < ActionController::TestCase
  test "should get data" do
    get :data
    assert_response :success
  end

  test "should get analytical" do
    get :analytical
    assert_response :success
  end

  test "should get view" do
    get :view
    assert_response :success
  end

end
