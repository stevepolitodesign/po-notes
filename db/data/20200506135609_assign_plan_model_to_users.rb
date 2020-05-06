class AssignPlanModelToUsers < ActiveRecord::Migration[6.0]
  def up
    @plan = Plan.new(name: "Free")
    User.update_all(plan: @plan)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
