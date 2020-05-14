require "test_helper"

class ReminderTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    Reminder.destroy_all
    @user = users(:user_1)
    @reminder = @user.reminders.build(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
  end

  test "should be valid" do
    assert @reminder.valid?
  end

  test "should have a user" do
    @reminder.user = nil
    assert_not @reminder.valid?
  end

  test "body should be less than 160 characters" do
    invalid_body = ("a" * 161)
    @reminder.body = invalid_body
    assert_not @reminder.valid?
  end

  test "time should be greater than current time by 30 minutes" do
    invalid_time = 30.minutes.from_now
    @reminder.time = invalid_time
    assert_not @reminder.valid?
    valid_time = 31.minutes.from_now
    @reminder.time = valid_time
    assert @reminder.valid?
  end

  test "time cannot be in the past" do
    invalid_time = 30.minutes.ago
    @reminder.time = invalid_time
    assert_not @reminder.valid?
  end

  test "time cannot be changed after create" do
    @reminder.save!
    @reminder.time = 1.year.from_now
    assert_not @reminder.valid?
  end

  test "should limit reminders created to the user's reminders_limit" do
    @plan = Plan.create(name: "Reminder Limit Test", tasks_limit: 25)
    @user.update(plan: @plan)
    25.times do |i|
      @user.reminders.create(name: "My Reminder #{i + 1}", body: "Some text", time: Time.zone.now + 1.day)
    end
    @reminder = @user.reminders.build(name: "Over the limit", body: "Some text", time: Time.zone.now + 1.day)
    assert_not @reminder.valid?
  end

  test "should set hashid" do
    assert_nil @reminder.hashid
    @reminder.save!
    assert_not_nil @reminder.hashid
  end

  test "should not change hashid on update" do
    @reminder.save!
    original_hashid = @reminder.hashid
    @reminder.update(name: "hashid should not update")
    assert_equal original_hashid, @reminder.reload.hashid
  end

  test "should use user_id as a slug candidate" do
    @reminder.save!
    @reminder_with_duplicate_hashid = @user.reminders.build(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day, hashid: @reminder.reload.hashid)
    @reminder_with_duplicate_hashid.save!
    assert_equal @reminder_with_duplicate_hashid.reload.slug.split("-").last.to_i, @reminder_with_duplicate_hashid.user_id
  end

  test "should order reminders by time in acsending order" do
    @reminder_hour = @user.reminders.create(name: "My Reminder 1 Hour In The Future", body: "Some text", created_at: Time.zone.now - 1.year, time: Time.zone.now + 1.hour)
    @reminder_day = @user.reminders.create(name: "My Reminder 1 Day In The Future", body: "Some text", created_at: Time.zone.now - 1.day, time: Time.zone.now + 1.day)
    @reminder_year = @user.reminders.create(name: "My Reminder 1 Year In The Future", body: "Some text", created_at: Time.zone.now - 1.hour, time: Time.zone.now + 1.year)
    assert_equal @reminder_hour, @user.reminders.first
  end

  test "should have a scope for upcoming reminders" do
    @past_reminder = @user.reminders.create(name: "My Past Reminder", body: "Some text", time: Time.zone.now + 31.minutes)
    @future_reminder = @user.reminders.create(name: "My Future Reminder", body: "Some text", time: Time.zone.now + 1.year)
    travel_to(Time.zone.now + 6.months)
    assert_equal 1, Reminder.upcoming.count
    assert_equal @future_reminder, Reminder.upcoming.first
  end

  test "should have a scope for past reminders" do
    @past_reminder = @user.reminders.create(name: "My Past Reminder", body: "Some text", time: Time.zone.now + 31.minutes)
    @future_reminder = @user.reminders.create(name: "My Future Reminder", body: "Some text", time: Time.zone.now + 1.year)
    travel_to(Time.zone.now + 6.months)
    assert_equal 1, Reminder.past.count
    assert_equal @past_reminder, Reminder.past.first
  end

  test "should have a scope for pending reminders" do
    @pending_reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day, sent: false)
    @unsent_reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
    assert_equal 1, Reminder.pending.count
    assert_equal @pending_reminder, Reminder.pending.first
  end

  test "should have a scope for unsent reminders" do
    @pending_reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day, sent: false)
    @unsent_reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
    assert_equal 1, Reminder.unsent.count
    assert_equal @unsent_reminder, Reminder.unsent.first
  end

  test "should have a scope for sent reminders" do
    @pending_reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day, sent: false)
    @sent_reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day, sent: true)
    assert_equal 1, Reminder.sent.count
    assert_equal @sent_reminder, Reminder.sent.first
  end

  test "should have a scope for ready_to_send reminders" do
    @unsent_reminder_no_within_delivery_window = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
    @unsent_reminder_within_delivery_window = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 31.minutes)
    travel_to(2.minutes.from_now)
    assert_equal 1, Reminder.ready_to_send.count
    assert_equal @unsent_reminder_within_delivery_window, Reminder.ready_to_send.first
  end

  test "ready_to_send reminders scope should account for different time_zones" do
    @user.update(time_zone: "Pacific Time (US & Canada)")
    assert_equal "Pacific Time (US & Canada)", @user.reload.time_zone
    @west_coast_reminder = @user.reminders.create(name: "My West Coast Reminder", body: "Some text", time: 31.minutes.from_now)
    @user.update(time_zone: "Eastern Time (US & Canada)")
    assert_equal "Eastern Time (US & Canada)", @user.reload.time_zone
    @east_coast_reminder = @user.reminders.create(name: "My East Coast Reminder", body: "Some text", time: 31.minutes.from_now)
    Time.zone = "UTC"
    assert_equal "UTC", Time.zone.name
    travel_to(2.minutes.from_now)
    assert_equal 2, Reminder.ready_to_send.count
    assert_includes Reminder.ready_to_send, @west_coast_reminder
    assert_includes Reminder.ready_to_send, @east_coast_reminder
  end

  test "should have a ready_to_destroy scope" do
    assert_equal 0, Reminder.ready_to_destroy.count
    @ready_to_destroy_reminder = @user.reminders.create(name: "Ready to Destroy", body: "Some Text", time: 31.minutes.from_now, sent: true)
    travel_to(32.minutes.from_now)
    assert_equal 1, Reminder.ready_to_destroy.count
    assert_includes Reminder.ready_to_destroy, @ready_to_destroy_reminder
  end

  test "should return send_sms early if reminder has been sent" do
    @sent_reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day, sent: true)
    assert_nil @sent_reminder.send_sms
  end

  test "should return send_sms early if user does not have a telephone" do
    @user.update(telephone: nil)
    @reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
    assert_nil @reminder.send_sms
  end

  test "send_sms should update sent to true" do
    @reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: 31.minutes.from_now)
    travel_to(2.minutes.from_now)
    VCR.use_cassette("twilio") do
      @reminder.send_sms
    end
    assert @reminder.reload.sent
  end

  test "send_sms should send to users telephone" do
    @reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
    VCR.use_cassette("twilio") do
      @response = @reminder.send_sms
      assert_equal "+#{@user.telephone}", @response.to
    end
  end

  test "send_sms should send reminder body" do
    @reminder = @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
    VCR.use_cassette("twilio") do
      @response = @reminder.send_sms
      assert_equal "Reminder: #{@reminder.name} start at #{time_ago_in_words(@reminder.time)} from now.", @response.body
    end
  end
end
