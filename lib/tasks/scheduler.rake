namespace :scheduler do
  task send_reminders: :environment do
    SendReminders.process
  end
  task destroy_reminders: :environment do
    DestroyReminders.process
  end
end
