require "application_system_test_case"

class UserFlowsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  def setup
    @user = users(:user_1)
  end

  test "can register" do
    @user.destroy
    visit root_path
    find_link("Create an Account").click
    find_field("Email").set("user_1@example.com")
    find_field("Password").set("password")
    find_field("Password confirmation").set("password")
    assert_emails 1 do
      find_button("Sign up").click
      sleep 2
    end
    email = ActionMailer::Base.deliveries.last
    assert_match "Confirm my account", email.body.encoded
    assert_equal ["user_1@example.com"], email.to
    assert_equal ["donotrely@po-notes.com"], email.from
    assert_match "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.", find(:xpath, "/html/body/div[1]/div/div[1]/p").text
    visit new_user_session_path
    find_field("Email").set("user_1@example.com")
    find_field("Password").set("password")
    find_button("Log in").click
  end

  test "can sign in" do
    visit root_path
    find_link("Log In").click
    find_field("Email").set(@user.email)
    find_field("Password").set("password")
    find_button("Log in").click
  end

  test "can sign out" do
    sign_in @user
    visit root_path
    find("#user-menu").click
    find_link("Sign Out").click
  end

  test "can cancel account" do
    sign_in @user
    visit root_path
    find("#user-menu").click
    find_link("Your Profile").click
    assert_difference("User.count", -1) do
      accept_alert do
        find_button("Cancel My Account").click
      end
      sleep 2
    end
  end

  test "can update email" do
    sign_in @user
    visit root_path
    find("#user-menu").click
    find_link("Your Profile").click
    find_field("Email").set("updated@example.com")
    find_field("Current password").set("password")
    assert_emails 1 do
      find_button("Update").click
      sleep 2
    end
    email = ActionMailer::Base.deliveries.last
    assert_equal ["updated@example.com"], email.to
    assert_equal "Confirmation instructions", email.subject
    assert_match "Confirm my account", email.body.encoded
  end

  test "can reset password" do
    visit root_path
    find_link("Log In").click
    find_link("Forgot your password?").click
    find_field("Email").set(@user.email)
    assert_emails 1 do
      find_button("Send me reset password instructions").click
      sleep 2
    end
    email = ActionMailer::Base.deliveries.last
    assert_equal [@user.email], email.to
    assert_equal "Reset password instructions", email.subject
    assert_match "Change my password", email.body.encoded
  end

  test "can resend confirmation instructions" do
    @user.update(confirmed_at: nil)
    visit root_path
    find_link("Log In").click
    find_link("Didn't receive confirmation instructions?").click
    find_field("Email").set(@user.email)
    assert_emails 1 do
      find_button("Resend confirmation instructions").click
      sleep 2
    end
    email = ActionMailer::Base.deliveries.last
    assert_equal [@user.email], email.to
    assert_equal "Confirmation instructions", email.subject
    assert_match "Confirm my account", email.body.encoded
  end

  test "should display validation errors on sign up" do
    @user.destroy
    visit root_path
    find_link("Create an Account").click
    find_field("Email").set("invalid@example.com")
    find_field("Password").set("1")
    find_field("Password confirmation").set("1")
    find_button("Sign up").click
    within("#error_explanation") do
      assert_match "Password is too short", find("li").text
    end
  end

  test "should display validation errors on sign in" do
    visit root_path
    find_link("Log In").click
    find_field("Email").set(@user.email)
    find_field("Password").set("wrong password")
    find_button("Log in").click
  end

  test "should update time_zone" do
    sign_in @user
    visit edit_user_registration_path
    find_field("Time zone").select("(GMT-05:00) Eastern Time (US & Canada)")
    find_field("Current password").set("password")
    find_button("Update").click
    visit edit_user_registration_path
    assert_equal "Eastern Time (US & Canada)", find_field("Time zone").value
  end

  test "should update telephone" do
    sign_in @user
    visit edit_user_registration_path
    find_field("Telephone").set("555-555-5555")
    find_field("Current password").set("password")
    find_button("Update").click
    visit edit_user_registration_path
    assert_equal "555-555-5555", find_field("Telephone").value
  end

  test "should allow user to set their time_zone on registration" do
    @user.destroy
    visit new_user_registration_path
    find_field("Email").set("user_1@example.com")
    find_field("Password").set("password")
    find_field("Password confirmation").set("password")
    find_field("Time zone").select("(GMT-05:00) Eastern Time (US & Canada)")
    assert_difference("User.count") do
      find_button("Sign up").click
    end
    assert_equal "Eastern Time (US & Canada)", User.last.time_zone
  end

  test "should allow user to set their telephone on registration" do
    @user.destroy
    visit new_user_registration_path
    find_field("Email").set("user_1@example.com")
    find_field("Password").set("password")
    find_field("Password confirmation").set("password")
    find_field("Telephone").set("555-555-5555")
    assert_difference("User.count") do
      find_button("Sign up").click
    end
    assert_equal "555-555-5555", User.last.telephone
  end
end
