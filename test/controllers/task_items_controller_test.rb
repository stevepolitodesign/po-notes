require "test_helper"

class TaskItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_1)
    @task = @user.tasks.create(title: Faker::Lorem.sentence)
    @task_item = @task.task_items.create(title: Faker::Lorem.sentence)
    @another_user = users(:user_2)
    @another_users_task = @another_user.tasks.create(title: Faker::Lorem.sentence)
    @another_users_task_item = @another_users_task.task_items.create(title: Faker::Lorem.sentence)
  end

  test "should post create if authenticated" do
    sign_in @user
    assert_difference("TaskItem.count") do
      post task_task_items_path(@task), params: {task_item: {title: "New Task"}}
    end
    assert_redirected_to @task
  end

  test "should not post create if authenticated but not owner of task" do
    sign_in @user
    assert_no_difference("TaskItem.count") do
      post task_task_items_path(@another_users_task), params: {task_item: {title: "New Task That Does Not Belong To Me"}}
    end
    user_not_authorized
  end

  test "should not post create if anonymous" do
    assert_no_difference("TaskItem.count") do
      post task_task_items_path(@task), params: {task_item: {title: "New Task"}}
    end
    assert_redirected_to new_user_session_path
  end

  test "should put update if authenticated" do
    sign_in @user
    put task_task_item_path(@task, @task_item), params: {task_item: {title: "Updated Task Item"}}
    assert_redirected_to @task
    assert_equal @task_item.reload.title, "Updated Task Item"
  end

  test "should not put update if authenticated but not task owner" do
    sign_in @user
    put task_task_item_path(@another_users_task, @another_users_task_item), params: {task_item: {title: "Updated Task Item"}}
    user_not_authorized
    assert_not_equal @another_users_task_item.reload.title, "Updated Task Item"
  end

  test "should not put update if anonymous" do
    put task_task_item_path(@another_users_task, @another_users_task_item), params: {task_item: {title: "Updated Task Item"}}
    assert_redirected_to new_user_session_path
    assert_not_equal @another_users_task_item.reload.title, "Updated Task Item"
  end

  test "should destroy if authenticated" do
    sign_in @user
    assert_difference("TaskItem.count", -1) do
      delete task_task_item_path(@task, @task_item)
    end
    assert_redirected_to @task
  end

  test "should not destroy if authenticated but not task owner" do
    sign_in @user
    assert_no_difference("TaskItem.count") do
      delete task_task_item_path(@another_users_task, @another_users_task_item)
    end
    user_not_authorized
  end

  test "should not destroy if anonymous" do
    assert_no_difference("TaskItem.count") do
      delete task_task_item_path(@task, @task_item)
    end
    assert_redirected_to new_user_session_path
  end
end
