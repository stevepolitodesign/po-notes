class AddSlugToReminders < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
  def change
    add_column :reminders, :slug, :string
    add_index :reminders, :slug, unique: true, algorithm: :concurrently
  end
end
