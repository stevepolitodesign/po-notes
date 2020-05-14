class CreatePlans < ActiveRecord::Migration[6.0]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.integer :notes_limit, null: false, default: 500
      t.integer :tasks_limit, null: false, default: 100
      t.integer :reminders_limit, null: false, default: 25

      t.timestamps
    end
  end
end
