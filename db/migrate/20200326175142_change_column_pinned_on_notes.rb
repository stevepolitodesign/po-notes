class ChangeColumnPinnedOnNotes < ActiveRecord::Migration[6.0]
  def change
    change_column_null :notes, :pinned, false
  end
end
