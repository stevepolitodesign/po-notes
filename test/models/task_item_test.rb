require "test_helper"

class TaskItemTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_1)
    @task = @user.tasks.create
    @task_item = @task.task_items.build
  end

  test "should be valid" do
    assert @task_item.valid?
  end

  test "should have a default title of 'Untitled'" do
    assert_equal @task_item.title, "Untitled"
  end

  test "should set complete to false by default" do
    assert_not @task_item.complete?
  end

  test "should belong to a task" do
    @task_item.task = nil
    assert_not @task_item.valid?
  end

  test "should auto increment position" do
    @task_item.save!
    assert_equal @task_item.position, 1
    @new_task_item = @task.task_items.create
    assert_equal @new_task_item.position, 2
  end
end
