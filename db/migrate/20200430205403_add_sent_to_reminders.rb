class AddSentToReminders < ActiveRecord::Migration[6.0]
  def change
    add_column :reminders, :sent, :boolean
  end
end
