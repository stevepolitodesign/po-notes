class RemoveTasksLimitFromUsers < ActiveRecord::Migration[6.0]
  def change
    safety_assured { remove_column :users, :tasks_limit, :integer }
  end
end
