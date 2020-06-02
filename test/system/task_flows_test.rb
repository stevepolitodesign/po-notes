require "application_system_test_case"

class TaskFlowsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_1)
  end

  test "should create task" do
    sign_in @user
    visit root_path
    find_link("Create Task").click
    find("#task_title").set("Build App")
    tag_field = find(".tagify__input")
    tag_field.send_keys("Personal")
    tag_field.send_keys(:tab)
    find_button("Create Task").click
    assert_match "Task added", find("#flash-message").text
  end

  test "should create task items" do
    @task = @user.tasks.create(title: "My Task")
    task_items = ["First Task Item", "Second Task Item"]
    sign_in @user
    visit task_path(@task)
    find_link("Add Task Items").click
    find("ol li:nth-child(1)").find_field("Title").set(task_items[0])
    find_link("Add Task Items").click
    find("ol li:nth-child(2)").find_field("Title").set(task_items[1])
    find_button("Update Task").click
    find("#flash-message")
    assert_equal task_items[0], find("ol li:nth-child(1)").find_field("Title").value
    assert_equal task_items[1], find("ol li:nth-child(2)").find_field("Title").value
  end

  test "should toggle task items complete when form loads" do
    @task = @user.tasks.create(title: "My Task")
    @task_item = @task.task_items.create(title: "Completed Task Item", complete: true)
    sign_in @user
    visit task_path(@task)
    assert find_field("Complete").checked?
    assert find("li").find_field("Title", disabled: true).disabled?
  end

  test "should toggle task items complete" do
    @task = @user.tasks.create(title: "My Task")
    @task_item = @task.task_items.create(title: "Completed Task Item", complete: false)
    sign_in @user
    visit task_path(@task)
    assert_not find_field("Complete").checked?
    assert_not find("li").find_field("Title").disabled?
    find_field("Complete").check
    assert find("li").find_field("Title", disabled: true).disabled?
  end

  test "should update task" do
    @task = @user.tasks.create(title: "My Task")
    @task.tag_list.add("Foo", "Bar")
    @task.save
    sign_in @user
    visit task_path(@task)
    find_field("Title").set("My Updated Task")
    tag_one = find(".tagify__tag-text", text: "foo")
    tag_one.double_click
    tag_one.send_keys(:backspace, :backspace, :backspace, "baz")
    tag_one.send_keys(:tab)
    tag_two = find("tag:last-of-type x")
    tag_two.click
    sleep 2
    click_button("Update Task")
    find("#flash-message")
    assert_equal "My Updated Task", find_field("Title").value
    find(".tagify__tag-text", text: "baz")
    assert_equal 1, all("tags tag").count
  end

  test "should update task items" do
    @task = @user.tasks.create(title: "My Task")
    3.times do |i|
      @task.task_items.create(title: "Task Item #{i + 1}", complete: false)
    end
    sign_in @user
    visit task_path(@task)
    find_field("Title") { |field| field.value == "Task Item 1" }.set("Updated Task Item 1")
    find_field("Title") { |field| field.value == "Task Item 2" }.set("Updated Task Item 2")
    find_field("Title") { |field| field.value == "Task Item 3" }.set("Updated Task Item 3")
    find_button("Update Task").click
    find("#flash-message")
    assert find_field("Title") { |field| field.value == "Updated Task Item 1" }
    assert find_field("Title") { |field| field.value == "Updated Task Item 2" }
    assert find_field("Title") { |field| field.value == "Updated Task Item 3" }
  end

  test "should drag and drop task items" do
    @task = @user.tasks.create(title: "My Task")
    3.times do |i|
      @task.task_items.create(title: "Task Item #{i + 1}", complete: false)
    end
    sign_in @user
    visit task_path(@task)
    item_one = find("ol li:nth-child(1)")
    item_three = find("ol li:nth-child(3)")
    item_one.find(".fa-bars", visible: false).drag_to(item_three)
    click_button("Update Task")
    find("#flash-message")
    assert_equal "Task Item 1", find("ol li:nth-child(3)").find_field("Title").value
  end

  test "should delete task" do
    @task = @user.tasks.create(title: "My Task")
    sign_in @user
    visit task_path(@task)
    assert_difference("Task.count", -1) do
      accept_alert do
        find_link("Delete Task").click
      end
      sleep 2
    end
    find("#flash-message")
  end

  test "should delete task items" do
    @task = @user.tasks.create(title: "My Task")
    3.times do |i|
      @task.task_items.create(title: "Task Item #{i + 1}", complete: false)
    end
    sign_in @user
    visit task_path(@task)
    find("ol li:nth-child(1)").find_link("Remove").click
    find("ol li:nth-child(2)").find_link("Remove").click
    find("ol li:nth-child(3)").find_link("Remove").click
    click_button("Update Task")
    assert_equal 0, all("ol li").count
  end

  test "should display form errors" do
    @task = @user.tasks.create(title: "My Invalid Task")
    50.times do |i|
      @task.task_items.create(title: "Task Item #{i + 1}", complete: false)
    end
    sign_in @user
    visit task_path(@task)
    find_link("Add Task Items").click
    find("ol li:nth-child(1)").find_field("Title").set("This should cause an error")
    click_button("Update Task")
    find("#error_explanation")
  end

  test "should display the amount of completed tasks on index view" do
    Task.destroy_all
    @task = @user.tasks.create(title: "My Task")
    @task.task_items.create(title: "Completed Task Item", complete: true)
    @task.task_items.create(title: "Incomplete Task Item", complete: false)
    sign_in @user
    visit tasks_path
    find("table tbody tr td") { |td| td.text == "1 / 2" }
  end

  test "should display a link to add a task if the user has no tasks" do
    Task.destroy_all
    sign_in @user
    visit tasks_path
    assert find_link("Add your first task")
  end

  test "should search tasks by title" do
    Task.destroy_all
    5.times do |i|
      @user.tasks.create(title: "Task #{i + 1}")
    end
    @user.tasks.create(title: "QWERTY")
    sign_in @user
    visit tasks_path
    find_field("Title contains").set("QWERTY")
    click_button("Search")
    assert_equal 1, all("table tbody tr").count
  end

  test "should search tasks by tag" do
    Task.destroy_all
    5.times do |i|
      @user.tasks.create(title: "Task #{i + 1}")
    end
    @task = @user.tasks.create(title: "Task with Tags")
    @task.tag_list.add("foo", "bar", "baz")
    @task.save
    sign_in @user
    visit tasks_path
    find_field("foo").check
    click_button("Search")
    assert_equal 1, all("table tbody tr").count
  end

  test "should display no results text if search yeilds no results" do
    Task.destroy_all
    @user.tasks.create(title: "My Task")
    sign_in @user
    visit tasks_path
    find_field("Title contains").set("QWERTY")
    click_button("Search")
    assert_equal 0, all("table tbody tr").count
    assert_equal 1, all("p") { |el| el.text == "Sorry, no tasks match your search." }.count
  end

  test "should paginate tasks" do
    Task.destroy_all
    51.times do |i|
      @user.tasks.create(title: "Task #{i + 1}")
    end
    sign_in @user
    visit tasks_path
    find_link("Last").click
    find_link("First").click
  end
end
