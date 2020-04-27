class SendReminderJob < ApplicationJob
  queue_as :default

  def perform(reminder)
    reminder.send_sms
  end
end
