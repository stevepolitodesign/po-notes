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
end
