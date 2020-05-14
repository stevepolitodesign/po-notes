class RemovePlanFromUsers < ActiveRecord::Migration[6.0]
  def change
    safety_assured { remove_column :users, :plan, :integer }
  end
end
