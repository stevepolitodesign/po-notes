class AddHashidToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :hashid, :string
  end
end
