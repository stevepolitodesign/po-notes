class DestroyReminders
  def self.process
    new.process
  end

  def process
    @reminders = Reminder.ready_to_destroy
    @reminders.each do |reminder|
      DestroyReminderJob.perform_later(reminder)
    end
  end
end
