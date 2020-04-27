# TODO Create cron job
class SendReminders
  def self.process
    new.process
  end

  def process
    @reminders = Reminder.ready_to_send.load
    @reminders.update_all(sent: false)
    @reminders.each do |reminder|
      SendReminderJob.perform_later(reminder)
    end
  end
end
