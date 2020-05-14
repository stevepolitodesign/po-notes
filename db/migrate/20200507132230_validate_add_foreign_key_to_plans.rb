class ValidateAddForeignKeyToPlans < ActiveRecord::Migration[6.0]
  def change
    validate_foreign_key :users, :plans
  end
end
