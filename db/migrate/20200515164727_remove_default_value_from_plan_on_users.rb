class RemoveDefaultValueFromPlanOnUsers < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :plan_id, nil
  end
end
