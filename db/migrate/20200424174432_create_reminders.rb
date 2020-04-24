class CreateReminders < ActiveRecord::Migration[6.0]
  def change
    create_table :reminders do |t|
      t.string :name
      t.text :body
      t.datetime :time
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
