require "test_helper"

class RemindersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    Reminder.delete_all
    @user = users(:user_1)
    @another_user = users(:user_2)
    @reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
  end

  test "should get index if authenticated" do
    sign_in @user
    get reminders_path
    assert_response :success
  end

  test "should not get index is anonymous" do
    get reminders_path
    assert_redirected_to new_user_session_path
  end

  test "should limit index reponse to current_user's reminders" do
    sign_in @user
    get reminders_path
    assert_match @reminder.name, @response.body
  end

  test "should get new if authenticated" do
    sign_in @user
    get new_reminder_path
    assert_response :success
  end

  test "should not get new if anonymous" do
    get new_reminder_path
    assert_redirected_to new_user_session_path
  end

  test "should get edit if authenticated and reminder owner" do
    sign_in @user
    get edit_reminder_path(@reminder)
    assert_response :success
  end

  test "should not get edit if authenticated but not reminder owner" do
    sign_in @another_user
    get edit_reminder_path(@reminder)
    user_not_authorized
  end

  test "should not get edit if anonymous" do
    get edit_reminder_path(@reminder)
    assert_redirected_to new_user_session_path
  end

  test "should post create if authenticated" do
    sign_in @user
    assert_difference("Reminder.count") do
      post reminders_path, params: {reminder: {name: "A New Reminder", body: "Some text", time: Time.zone.now + 1.day}}
    end
    assert_redirected_to reminders_path
  end

  test "should limit post create to current_user" do
    sign_in @another_user
    assert_equal 0, @another_user.reminders.count
    post reminders_path, params: {reminder: {name: "A New Reminder", body: "Some text", time: Time.zone.now + 1.day, user: @user}}
    assert_equal 1, @another_user.reload.reminders.count
  end

  test "should not post create if anonymous" do
    assert_no_difference("Reminder.count") do
      post reminders_path, params: {reminder: {name: "A New Reminder", body: "Some text", time: Time.zone.now + 1.day, user: @user}}
    end
    assert_redirected_to new_user_session_path
  end

  test "should put update if authenticated and reminder owner" do
    sign_in @user
    new_name = "Updated Title"
    put reminder_path(@reminder), params: {reminder: {name: new_name}}
    assert_equal new_name, @reminder.reload.name
    assert_redirected_to reminders_path
  end

  test "should not put update if authenticated but not reminder owner" do
    sign_in @another_user
    original_name = @reminder.name
    new_name = "Updated Title"
    put reminder_path(@reminder), params: {reminder: {name: new_name}}
    assert_equal original_name, @reminder.reload.name
    user_not_authorized
  end

  test "should not put update if anonymous" do
    original_name = @reminder.name
    new_name = "Updated Title"
    put reminder_path(@reminder), params: {reminder: {name: new_name}}
    assert_equal original_name, @reminder.reload.name
  end

  test "should destroy if authenticated and reminder owner" do
    sign_in @user
    assert_difference("Reminder.count", -1) do
      delete reminder_path(@reminder)
    end
    assert_redirected_to reminders_path
  end

  test "should not destroy if authenticated but not reminder owner" do
    sign_in @another_user
    assert_no_difference("Reminder.count") do
      delete reminder_path(@reminder)
    end
    user_not_authorized
  end

  test "should not destroy if anonymous" do
    assert_no_difference("Reminder.count") do
      delete reminder_path(@reminder)
    end
    assert_redirected_to new_user_session_path
  end

  test "should save time in users time_zone" do
    Reminder.destroy_all
    sign_in @user
    @user.update(time_zone: "Eastern Time (US & Canada)")
    post reminders_path, params: {reminder: {name: "A New Reminder", body: "Some text", time: 1.hour.from_now}}
    assert_equal "EDT", @user.reload.reminders.first.time.zone
  end
end
