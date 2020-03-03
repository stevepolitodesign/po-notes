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
    skip
  end  

  test "can update account" do
    skip
  end

  test "can reset password" do
    skip
  end

  test "can resend onfirmation instructions" do
    skip
  end

end
