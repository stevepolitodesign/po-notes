require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_1)
    @another_user = users(:user_2)
    @task = @user.tasks.create(title: Faker::Lorem.sentence)
    @task_item = @task.task_items.create(title: Faker::Lorem.sentence)
  end

  test "should get index if authenticated" do
    sign_in @user
    get tasks_path
    assert_response :success
  end

  test "should not get index if anonymous" do
    get tasks_path
    assert_redirected_to new_user_session_path
  end

  test "should get edit if authenticated and owner" do
    sign_in @user
    get edit_task_path(@task)
    assert_response :success
  end

  test "should not get edit if authenticated but not owner" do
    sign_in @another_user
    get edit_task_path(@task)
    user_not_authorized
  end

  test "should not get edit if anonymous" do
    get edit_task_path(@task)
    assert_redirected_to new_user_session_path
  end

  test "should get new if authenticated" do
    sign_in @user
    get new_task_path
    assert_response :success
  end

  test "should not get new if anonymous" do
    get new_task_path
    assert_redirected_to new_user_session_path
  end

  test "should post create if authenticated" do
    sign_in @user
    assert_difference("Task.count") do
      post tasks_path, params: {task: {title: "New Task", user: @user}}
    end
    assert_redirected_to @user.reload.tasks.first
  end

  test "should not post create if anonymous" do
    assert_no_difference("Task.count") do
      post tasks_path, params: {task: {title: "New Task", user: @user}}
    end
    assert_redirected_to new_user_session_path
  end

  test "should put update if authenticated and owner" do
    sign_in @user
    put task_path(@task), params: {task: {title: "updated"}}
    assert_equal @task.reload.title, "updated"
    assert_redirected_to task_path(@task)
  end

  test "should not put update if authenticated but not owner" do
    sign_in @another_user
    put task_path(@task), params: {task: {title: "updated"}}
    assert_not_equal @task.reload.title, "updated"
    user_not_authorized
  end

  test "should not put update if anonymous" do
    put task_path(@task), params: {task: {title: "updated"}}
    assert_not_equal @task.reload.title, "updated"
    assert_redirected_to new_user_session_path
  end

  test "should destroy if authenticated and owner" do
    sign_in @user
    assert_difference("Task.count", -1) do
      delete task_path(@task)
    end
    assert_redirected_to tasks_path
  end

  test "should not destroy if authenticated but not owner" do
    sign_in @another_user
    assert_no_difference("Task.count") do
      delete task_path(@task)
    end
    user_not_authorized
  end

  test "should not destroy if anonymous" do
    assert_no_difference("Task.count") do
      delete task_path(@task)
    end
    assert_redirected_to new_user_session_path
  end
end
