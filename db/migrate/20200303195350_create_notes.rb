class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.string :title, default: "Untitled"
      t.text :body
      t.boolean :pinned, default: false
      t.boolean :public, default: false
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
