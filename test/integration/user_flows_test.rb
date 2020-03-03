require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  test "can register" do
    get new_user_registration_path
    assert_select '#new_user' do
      assert_select 'input#user_email'
      assert_select 'input#user_password'
      assert_select 'input#user_password_confirmation'
    end
  end

  test "can sign in" do
    skip
  end
  
  test "can sign out" do
    skip
  end

  test "can cancel account" do
    skip
  end
end
