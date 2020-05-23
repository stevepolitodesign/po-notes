require 'test_helper'

class ImportNotesJobTest < ActiveJob::TestCase
  def setup
    @user = users(:user_1)
    @file = file_fixture("notes.csv").read
  end

  test "should import notes" do
    assert_difference("Note.count") do
      ImportNotesJob.perform_now(file: @file, user: @user)
    end
  end
  
end
