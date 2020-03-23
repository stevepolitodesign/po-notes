class AddTasksLimitToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :tasks_limit, :integer, default: 100
  end
end
