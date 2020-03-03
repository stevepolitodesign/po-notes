require "application_system_test_case"

class UserFlowsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  def setup
    @user = users(:one)
  end
  
  test "can register" do
    @user.destroy
    visit root_path
    click_link 'Sign Up'
    fill_in 'Email', with: 'user_1@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    assert_emails 1 do
      click_on 'Sign up'
    end
    email = ActionMailer::Base.deliveries.last
    assert_match 'Confirm my account', email.body.encoded
    assert_equal ['user_1@example.com'], email.to
    assert_equal ['donotrely@po-notes.com'], email.from
    assert_selector 'div', text: 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
    visit new_user_session_path
    fill_in 'Email', with: 'user_1@example.com'
    fill_in 'Password', with: 'password'
    click_on 'Log in'
    assert_selector 'div', text: 'You have to confirm your email address before continuing.'
  end

  test "can sign in" do
    visit root_path
    click_link 'Sign In'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'password'
    click_on 'Log in'
    assert_selector 'div', text: 'Signed in successfully'
  end
  
  test "can sign out" do
    sign_in @user
    visit root_path
    click_link 'Log out'
    assert_selector 'div', text: 'Signed out successfully'
  end

  test "can cancel account" do
    sign_in @user
    visit root_path
    click_link 'My Account'
    assert_difference('User.count', -1) do
      accept_alert do
        click_on 'Cancel my account'
      end
      sleep 1
    end
  end  

  test "can update email" do
    sign_in @user
    visit root_path
    click_link 'My Account'
    fill_in 'Email', with: 'updated@example.com'
    fill_in 'Current password', with: 'password'
    assert_emails 1 do
      click_on 'Update'
    end
    email = ActionMailer::Base.deliveries.last
    assert_equal ['updated@example.com'], email.to
    assert_equal 'Confirmation instructions', email.subject
    assert_match 'Confirm my account', email.body.encoded
    assert_selector 'div', text: 'You updated your account successfully, but we need to verify your new email address. Please check your email and follow the confirmation link to confirm your new email address.'
  end

  test "can reset password" do
    skip
  end

  test "can resend confirmation instructions" do
    skip
  end

  test "should display validation errors on sign up" do
    skip
  end

  test "should display validation errors on sign in" do
    skip
  end  

end
