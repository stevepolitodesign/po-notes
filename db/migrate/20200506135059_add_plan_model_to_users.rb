class AddPlanModelToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :plan, null: false, foreign_key: true
  end
end
