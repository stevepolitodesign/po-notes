require "application_system_test_case"

class UserFlowsTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  test "can register" do
    visit new_user_registration_path
    fill_in 'Email', with: 'user_1@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    assert_emails 1 do
      click_on 'Sign up'
    end
    page.find('body', text: 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.')
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

  test "can update account" do
    skip
  end

end
