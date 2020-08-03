require "test_helper"

class SendReminderJobTest < ActiveJob::TestCase
  def setup
    Reminder.destroy_all
    @user = users(:user_1)
    @reminder = @user.reminders.build(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
  end

  test "should enqueue job" do
    @reminder.save
    SendReminderJob.perform_later(@reminder)
    assert_enqueued_with(job: SendReminderJob, args: [@reminder])
  end

  test "should call send_sms method if passed a reminder" do
    @reminder.save
    VCR.use_cassette("twilio") do
      @response = SendReminderJob.perform_now(@reminder)
      assert @reminder.sent?
      assert_match "Reminder: #{@reminder.name} starts in #{time_ago_in_words(@reminder.time)}.", @response.body
    end
  end

  test "should set sent to true" do
    @reminder.save
    VCR.use_cassette("twilio") do
      SendReminderJob.perform_now(@reminder)
      assert_includes Reminder.sent, @reminder
    end
  end
end
