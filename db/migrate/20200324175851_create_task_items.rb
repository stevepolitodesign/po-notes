class CreateTaskItems < ActiveRecord::Migration[6.0]
  def change
    create_table :task_items do |t|
      t.string :title, null: false, default: "Untitled"
      t.boolean :complete, null: false, default: false
      t.integer :position
      t.belongs_to :task, null: false, foreign_key: true

      t.timestamps
    end
  end
end
