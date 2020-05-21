class ImportNotesJob < ApplicationJob
  queue_as :default

  def perform(file, user)
  end

  private 

  def parse_csv
  end

  def save_note
  end
end
