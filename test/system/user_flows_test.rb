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
    find_link("Sign Up").click
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
    assert_match "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.", find("#flash-message").text
    visit new_user_session_path
    find_field("Email").set("user_1@example.com")
    find_field("Password").set("password")
    find_button("Log in").click
    assert_match "You have to confirm your email address before continuing.", find("#flash-message").text
  end

  test "can sign in" do
    visit root_path
    find_link("Sign In").click
    find_field("Email").set(@user.email)
    find_field("Password").set("password")
    find_button("Log in").click
    assert_match "Signed in successfully", find("#flash-message").text
  end

  test "can sign out" do
    sign_in @user
    visit root_path
    find_link("Log out").click
    assert_match "Signed out successfully", find("#flash-message").text
  end

  test "can cancel account" do
    sign_in @user
    visit root_path
    find_link("My Account").click
    assert_difference("User.count", -1) do
      accept_alert do
        find_button("Cancel my account").click
      end
      sleep 2
    end
  end

  test "can update email" do
    sign_in @user
    visit root_path
    find_link("My Account").click
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
    assert_match "You updated your account successfully, but we need to verify your new email address. Please check your email and follow the confirmation link to confirm your new email address.", find("#flash-message").text
  end

  test "can reset password" do
    visit root_path
    find_link("Sign In").click
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
    assert_match "You will receive an email with instructions on how to reset your password in a few minutes.", find("#flash-message").text
  end

  test "can resend confirmation instructions" do
    @user.update(confirmed_at: nil)
    visit root_path
    find_link("Sign In").click
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
    assert_match "You will receive an email with instructions for how to confirm your email address in a few minutes.", find("#flash-message").text
  end

  test "should display validation errors on sign up" do
    @user.destroy
    visit root_path
    find_link("Sign Up").click
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
    find_link("Sign In").click
    find_field("Email").set(@user.email)
    find_field("Password").set("wrong password")
    find_button("Log in").click
    assert_match "Invalid Email or password.", find("#flash-message").text
  end
end
