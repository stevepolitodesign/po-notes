require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_1)
    @task = Task.new(title: "Task Title", user: @user)
  end

  test "should be valid" do
    assert @task.valid?
  end

  test "should have a user" do
    @task.user = nil
    assert_not @task.valid?
  end

  test "should have a defaul title value of 'Untitled'" do
    @task = @user.tasks.build
    @task.save!
    assert_equal @task.title, "Untitled"
  end

  test "can have many tags" do
    assert_equal @task.tag_list.length, 0
    @task.tag_list.add("personal", "work")
    assert_equal @task.tag_list.length, 2
  end

  test "should order by last updated" do
    @user.tasks.destroy_all
    1.upto(10) do |i|
      @task = @user.tasks.build(title: "task-title-#{i}", user: @user)
      assert @task.valid?
      @task.save!
    end
    assert_equal @user.tasks.reload.last.title, "task-title-1"
    @user.tasks.last.update(title: "update task")
    assert_equal @user.tasks.reload.first.title, "update task"
  end

  test "should set hashid" do
    assert_nil @task.hashid
    @task.save!
    assert_not_nil @task.hashid
  end

  test "should not change hashid on update" do
    @task.save!
    original_hashid = @task.hashid
    @task.update(title: "hashid should not update")
    assert_equal original_hashid, @task.reload.hashid
  end

  test "should use user_id as a slug candidate" do
    @task.save!
    @task_with_duplicate_hashid = @user.tasks.build(title: "Duplicate hashid", hashid: @task.reload.hashid)
    @task_with_duplicate_hashid.save!
    assert_equal @task_with_duplicate_hashid.reload.slug.split("-").last.to_i, @task_with_duplicate_hashid.user_id
  end

  test "should not create duplicate tags" do
    @task.tag_list.add("one", "One", "oNe", "Two", "two")
    @task.save!
    assert_equal @task.reload.tag_list, ["one", "two"]
  end

  test "should lowercase tags" do
    @task.tag_list.add("ONE")
    @task.save!
    assert_equal @task.reload.tag_list, ["one"]
  end

  test "should parse tag list" do
    @task.tag_list.add('[{"value":"one"}', '{"value":"two"}]')
    @task.save!
    assert_equal @task.reload.tag_list, ["one", "two"]
  end

  test "should limit tasks created to the user's plan's tasks_limit" do
    @plan = Plan.create(name: "Task Limit Test", tasks_limit: 100)
    @user.update(plan: @plan)
    @user.tasks.destroy_all
    100.times do |n|
      @task = @user.tasks.build(title: "title #{n}")
      assert @task.valid?
      @task.save!
    end
    assert_equal @user.reload.tasks.count, 100
    @task = @user.tasks.build(title: "Note 101")
    assert_not @task.valid?
    assert_equal @task.errors.messages[:user_id][0], "has reached their task limit"
  end

  test "should destroy associated task_items" do
    @task.save!
    @task.task_items.destroy_all
    3.times do |i|
      @task_item = @task.task_items.build
      @task_item.save! if @task_item.valid?
    end
    assert_difference("TaskItem.count", -3) do
      @task.task_items.destroy_all
    end
  end

  test "should order associated task_items by their position" do
    @task.save!
    @task.task_items.destroy_all
    1.upto(3) do |i|
      @task_item = @task.task_items.build(title: "Item #{i}", position: i)
      @task_item.save! if @task_item.valid?
    end
    assert_equal @task.reload.task_items.first.title, "Item 1"
  end

  test "should not have more than 50 task_items" do
    @task.save!
    1.upto(50) do |i|
      @task.task_items.create(title: "Task Item #{i}")
    end
    assert_equal 50, @task.task_items.count
    @task_item = @task.task_items.build(title: "Task Item 51")
    assert_not @task.valid?
  end
end
