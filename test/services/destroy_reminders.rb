require "test_helper"

class DestroyRemindersTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    Reminder.destroy_all
    @user = users(:user_1)
  end

  test "should exist" do
    assert defined?(DestroyReminders)
  end

  test "should enqueue DestroyReminderJob for each instance of a reminder that is ready to be destroyed" do
    @reminder_to_be_destroyed = @user.reminders.create(name: "Should not be destroyed", body: "Some text", time: 31.minutes.from_now, sent: true)
    travel_to(32.minutes.from_now)
    Reminder.ready_to_destroy.each do |reminder|
      assert_enqueued_with(job: DestroyReminderJob, args: reminder) do
        DestroyReminders.process
      end
      assert_enqueued_jobs Reminder.ready_to_destroy.count
    end
  end
end
