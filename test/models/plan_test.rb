require "test_helper"

class PlanTest < ActiveSupport::TestCase
  def setup
    @plan = Plan.new(name: "Free")
  end

  test "should be valid" do
    assert @plan.valid?
  end

  test "should have a name" do
    @plan.name = nil
    assert_not @plan.valid?
  end

  test "should have a unique name" do
    @plan.save!
    @invalid_plan = Plan.new(name: @plan.name)
    assert_not @invalid_plan.valid?
  end

  test "should have a notes_limit" do
    @plan.notes_limit = nil
    assert_not @plan.valid?
  end

  test "should have a tasks_limit" do
    @plan.tasks_limit = nil
    assert_not @plan.valid?
  end

  test "should have a reminders_limit" do
    @plan.reminders_limit = nil
    assert_not @plan.valid?
  end

  test "notes_limit should have a default value of 500" do
    @plan.save!
    assert_equal 500, @plan.reload.notes_limit
  end

  test "tasks_limit should have a default value of 500" do
    @plan.save!
    assert_equal 100, @plan.reload.tasks_limit
  end

  test "reminders_limit should have a default value of 500" do
    @plan.save!
    assert_equal 25, @plan.reload.reminders_limit
  end
  
  test "cannot be destroyed if assoicated with a user" do
    flunk
  end
end
