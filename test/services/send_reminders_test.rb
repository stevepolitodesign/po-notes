require "test_helper"

class SendRemindersTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    Reminder.destroy_all
    @user = users(:user_1)
    @reminder = @user.reminders.build(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
  end

  test "should exist" do
    assert defined?(SendReminders)
  end

  test "should enqueue SendReminderJob job for each instance of a Reminder that is ready_to_send" do
    @user.update(time_zone: "Pacific Time (US & Canada)")
    assert_equal "Pacific Time (US & Canada)", @user.reload.time_zone
    @west_coast_reminder = @user.reminders.create(name: "My West Coast Reminder", body: "Some text", time: 31.minutes.from_now)
    @user.update(time_zone: "Eastern Time (US & Canada)")
    assert_equal "Eastern Time (US & Canada)", @user.reload.time_zone
    @east_coast_reminder = @user.reminders.create(name: "My East Coast Reminder", body: "Some text", time: 31.minutes.from_now)
    Time.zone = "UTC"
    assert_equal "UTC", Time.zone.name
    travel_to(2.minutes.from_now)
    Reminder.ready_to_send do |reminder|
      assert_enqueued_with(job: SendReminderJob, args: reminder) do
        SendReminders.process
        assert_enqueued_jobs Reminder.ready_to_send.count
      end
    end
  end

  test "should set sent to false" do
    @reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: 31.minutes.from_now)
    assert_nil @reminder.sent
    travel_to(2.minutes.from_now)
    SendReminders.process
    assert_includes Reminder.pending, @reminder
  end
end
