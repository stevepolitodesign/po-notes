class AddPlanModelToUsers < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_reference :users, :plan, null: false, default: 1, index: {algorithm: :concurrently}
  end
end
