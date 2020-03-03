require "application_system_test_case"

class UserFlowsTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  def setup
    @user = users(:one)
  end
  
  test "can register" do
    @user.destroy
    visit new_user_registration_path
    fill_in 'Email', with: 'user_1@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    assert_emails 1 do
      click_on 'Sign up'
    end
    assert_selector 'div', text: 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
    visit new_user_session_path
    fill_in 'Email', with: 'user_1@example.com'
    fill_in 'Password', with: 'password'
    click_on 'Log in'
    assert_selector 'div', text: 'You have to confirm your email address before continuing.'
  end

  test "can sign in" do
    visit new_user_session_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'password'
    click_on 'Log in'
    assert_selector 'div', text: 'Signed in successfully'
  end
  
  test "can sign out" do
    skip
  end

  test "can cancel account" do
    skip
  end  

  test "can update account" do
    skip
  end

end
