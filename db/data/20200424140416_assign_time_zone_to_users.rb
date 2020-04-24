class AssignTimeZoneToUsers < ActiveRecord::Migration[6.0]
  def up
    User.update_all "time_zone = 'UTC'"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
