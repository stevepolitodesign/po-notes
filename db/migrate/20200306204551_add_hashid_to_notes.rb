class AddHashidToNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :notes, :hashid, :string
  end
end
