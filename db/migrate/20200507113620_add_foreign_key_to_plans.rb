class AddForeignKeyToPlans < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :users, :plans
  end
end
