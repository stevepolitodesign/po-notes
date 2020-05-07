class CreatePlan < ActiveRecord::Migration[6.0]
  def up
    Plan.create(name: "Free")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
