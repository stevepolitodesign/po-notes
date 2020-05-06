class CreatePlans < ActiveRecord::Migration[6.0]
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :notes_limit
      t.integer :tasks_limit
      t.integer :reminders_limit

      t.timestamps
    end
  end
end
