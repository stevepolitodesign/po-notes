class ChangeTitleColumnDefaultOnTasks < ActiveRecord::Migration[6.0]
  def change
    change_column_default :tasks, :title, "Untitled"
  end
end
