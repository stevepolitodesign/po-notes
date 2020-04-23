class AddPlanToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :plan, :integer, null: false, default: 0
  end
end
