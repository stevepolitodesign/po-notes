class ChangeTitleColumnOnNotesAndTasks < ActiveRecord::Migration[6.0]
  def change
    change_column_null :notes, :title, false
    change_column_null :tasks, :title, false
  end
end
