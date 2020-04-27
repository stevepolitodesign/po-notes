require "test_helper"

class DestroyReminderJobTest < ActiveJob::TestCase
  def setup
    Reminder.destroy_all
    @user = users(:user_1)
  end
  test "should destroy reminders in ready_to_destroy scope" do
    @reminder_not_to_be_destroyed = @user.reminders.create(name: "Should not be destroyed", body: "Some text", time: 1.day.from_now)
    @reminder_to_be_destroyed = @user.reminders.create(name: "Should not be destroyed", body: "Some text", time: 31.minutes.from_now, sent: true)
    travel_to(32.minutes.from_now)
    @reminders = Reminder.ready_to_destroy
    @reminders.each do |reminder|
      assert_difference("Reminder.count", -1) do
        DestroyReminderJob.perform_now(reminder)
      end
    end
  end
end
