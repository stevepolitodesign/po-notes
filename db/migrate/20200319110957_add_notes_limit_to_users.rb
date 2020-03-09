class AddNotesLimitToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :notes_limit, :integer, default: 500
  end
end
