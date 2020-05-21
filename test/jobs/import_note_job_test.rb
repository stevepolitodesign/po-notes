require 'test_helper'

class ImportNoteJobTest < ActiveJob::TestCase
  def setup
    @user = users(:user_1)
    @note = Note.new(title: "A new note", body: "Some text")
    @note.tag_list.add("tag 1", "tag 2")
  end

  test "should create a new note" do
    assert_difference("Note.count") do
      ImportNoteJob.perform_now(@note, @user)
    end
  end
  
end
