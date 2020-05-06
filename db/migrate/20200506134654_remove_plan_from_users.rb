class RemovePlanFromUsers < ActiveRecord::Migration[6.0]
  def change

    remove_column :users, :plan, :integer
  end
end
