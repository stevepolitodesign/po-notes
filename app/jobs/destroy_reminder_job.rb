class DestroyReminderJob < ApplicationJob
  queue_as :default

  def perform(reminder)
    reminder&.destroy
  end
end
