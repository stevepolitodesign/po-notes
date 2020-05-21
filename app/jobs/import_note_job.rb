class ImportNoteJob < ApplicationJob
  queue_as :default

  def perform(note, user)
    note.user = user
    note.save
  end
end
