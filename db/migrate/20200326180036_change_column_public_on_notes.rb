class ChangeColumnPublicOnNotes < ActiveRecord::Migration[6.0]
  def change
    change_column_null :notes, :public, false
  end
end
