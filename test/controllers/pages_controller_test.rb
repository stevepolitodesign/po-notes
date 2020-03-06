require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_1)
  end

  test "should set home as root when logged out" do
    get root_url
    assert_response :success
    assert_equal @controller.action_name, 'home'
  end

  test "should get dashboard" do
    sign_in @user
    get root_url
    assert_response :success
    assert_equal @controller.action_name, 'dashboard'
  end

end
