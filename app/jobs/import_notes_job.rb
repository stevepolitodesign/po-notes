
require "csv"
class ImportNotesJob < ApplicationJob
  queue_as :default

  def perform(file, user)
  end

  private 

  # TODO Should only parse as many row's as the user's plan's notes_limit
  def parse_csv
  end

  def save_note
  end
end
