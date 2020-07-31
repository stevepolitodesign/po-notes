require "application_system_test_case"

class ReminderFlowsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def setup
    Reminder.destroy_all
    @user = users(:user_1)
  end

  test "should display a list of reminders" do
    sign_in @user
    1.upto(10) do |i|
      @user.reminders.create(name: "My Reminder #{i}", body: "Some text", time: Time.zone.now + i.day)
    end
    visit reminders_path
    @user.reminders.each do |reminder|
      find("td") { |el| el.text == reminder.name }
    end
  end

  test "should have no result behavior" do
    sign_in @user
    visit root_path
    find_link("Reminders").click
    find_link("Add a Reminder").click
  end

  test "should alert user if they do not have a phone number" do
    @user.update(telephone: nil)
    assert_nil @user.reload.telephone
    sign_in @user
    visit new_reminder_path
    find_link("Add your telephone number", href: edit_user_registration_path)
  end

  test "should create a reminder" do
    sign_in @user
    visit reminders_path
    find_link("Add a Reminder").click
    find_field("Name").set("My new reminder")
    Time.zone = @user.time_zone
    find_field("Time").set(Time.zone.now + 1.hour)
    editor = find(".CodeMirror")
    editor.click
    editor.find("textarea", visible: :all).send_keys("Some descriptive text to give my reminder contenxt.")
    find_button("Create Reminder").click
    assert_match "Reminder added", find(:xpath, "/html/body/div/div[1]/div/div[1]/p").text
  end

  test "should update a reminder" do
    @reminder = @user.reminders.create(name: "My reminder", time: 1.hour.from_now, body: "just some text")
    sign_in @user
    visit reminders_path
    find_link("Edit Reminder", href: edit_reminder_path(@reminder)).click
    find_field("Name").set("My updated reminder name")
    editor = find(".CodeMirror")
    editor.click
    @reminder.body.length.times do |n|
      editor.find("textarea", visible: :all).send_keys(:backspace)
    end
    editor.find("textarea", visible: :all).send_keys("My updated reminder body")
    find_button("Update Reminder").click
    assert_match "Reminder updated", find(:xpath, "/html/body/div/div[1]/div/div[1]/p").text
    find_link("Edit Reminder", href: edit_reminder_path(@reminder)).click
    assert_equal "My updated reminder name", find_field("Name").value
    assert_equal "My updated reminder body", find(".CodeMirror-lines .CodeMirror-code span").text, "My updated redminder body"
  end

  test "should destroy a reminder" do
    @reminder = @user.reminders.create(name: "My reminder", time: 1.hour.from_now, body: "just some text")
    sign_in @user
    visit edit_reminder_path(@reminder)
    assert_difference("Reminder.count", -1) do
      accept_alert do
        find_link("Delete Reminder").click
      end
      sleep 2
    end
    assert_match "Reminder deleted", find(:xpath, "/html/body/div/div[1]/div/div[1]/p").text
  end

  test "should display user's time_zone on form" do
    sign_in @user
    visit new_reminder_path
    find_link(@user.time_zone, href: edit_user_registration_path)
  end

  test "should display errors during validation" do
    sign_in @user
    visit new_reminder_path
    find_button("Create Reminder").click
    find("#error_explanation")
  end
end
