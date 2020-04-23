class RemoveNotesLimitFromUsers < ActiveRecord::Migration[6.0]
  def change
    safety_assured { remove_column :users, :notes_limit, :integer }
  end
end
