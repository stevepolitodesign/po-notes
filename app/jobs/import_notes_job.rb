require "csv"
class ImportNotesJob < ApplicationJob
  queue_as :default

  def perform(file:, user:, limit: nil)
    rows = if limit
      CSV.read(file, headers: true, header_converters: :symbol).take(limit)
    else
      CSV.read(file, headers: true, header_converters: :symbol)
    end
    rows.each do |row|
      @note = Note.new(title: row[:title], body: row[:body], user: user)
      @note.tag_list.add(row[:tags].split(",")) if row[:tags]
      @note.save if @note.valid?
    end
  end
end
