require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: "user@example.com", password: "password", password_confirmation: "password", confirmed_at: Time.zone.now)
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "should destroy associated notes" do
    @user.save!
    5.times do |n|
      @note = @user.notes.build(title: "title #{n}", body: "body #{n}")
      assert @note.valid?
      @note.save!
    end
    assert_equal @user.reload.notes.length, 5
    notes_count = @user.reload.notes.length
    assert_difference("Note.count", -notes_count.to_s.to_i) do
      @user.destroy
    end
  end

  test "should destroy associated tasks" do
    @user.save!
    5.times do |n|
      @task = @user.tasks.build(title: "title #{n}")
      assert @task.valid?
      @task.save!
    end
    assert_equal @user.reload.tasks.length, 5
    tasks_count = @user.reload.tasks.length
    assert_difference("Task.count", -tasks_count.to_s.to_i) do
      @user.destroy
    end
  end

  test "should destroy associated task items" do
    @user.save!
    @task = @user.tasks.build(title: "My Task")
    @task.save!
    @task_item = @task.task_items.build
    @task_item.save!
    assert_difference("TaskItem.count", -1) do
      @user.destroy
    end
  end

  test "should have a default plan of free" do
    @user = User.new
    assert_equal "free", @user.plan
  end

  test "should have a plan" do
    @user.plan = nil
    assert_raises("ActiveRecord::NotNullViolation") do
      @user.save
    end
  end

  test "should have time_zone" do
    @user.time_zone = nil
    assert_not @user.valid?
  end

  test "should have default time_zone of 'UTC'" do
    assert_equal "UTC", @user.time_zone
  end

  test "should be a valid time_zone" do
    invalid_time_zones = %w[foo bar bax]
    invalid_time_zones.each do |invalid_time_zone|
      @user.time_zone = invalid_time_zone
      assert_not @user.valid?
    end
    valid_time_zones = ActiveSupport::TimeZone.all.map { |tz| tz.name }
    valid_time_zones.each do |valid_time_zone|
      @user.time_zone = valid_time_zone
      assert @user.valid?
    end
  end

  test "should destroy associated reminders" do
    Reminder.destroy_all
    @user.save
    @user.reminders.create(name: "My Reminder", body: "Some text", time: Time.zone.now + 1.day)
    assert_difference("Reminder.count", -1) do
      @user.destroy
    end
  end

  test "should be valid without telephone" do
    @user.telephone = nil
    assert @user.valid?
  end

  test "should be invalid if telephone is invalid" do
    invalid_numbers = ["12345", "foo bar", "555-555"]
    invalid_numbers.each do |invalid_number|
      @user.telephone = invalid_number
      assert_not @user.valid?
    end
  end

  test "should have a plan" do
    flunk
  end
end
