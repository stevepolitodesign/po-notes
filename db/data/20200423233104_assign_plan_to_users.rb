class AssignPlanToUsers < ActiveRecord::Migration[6.0]
  def up
    User.update_all "plan = 0"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
