require "test_helper"

class ReminderTest < ActiveSupport::TestCase
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

  test "should limit reminders created to the user's reminders_limit" do
    @user.update(plan: "free")
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
end
