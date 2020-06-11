require "test_helper"
require "csv"
class ImportNotesJobTest < ActiveJob::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  def setup
    @user = users(:user_1)
    @file = file_fixture("notes.csv")
  end

  test "should import notes" do
    assert_difference("Note.count", @file.readlines.size - 1) do
      ImportNotesJob.perform_now(file: fixture_file_upload(@file), user: @user)
    end
  end

  test "should limit created notes" do
    assert_difference("Note.count", 1) do
      ImportNotesJob.perform_now(file: fixture_file_upload(@file), user: @user, limit: 1)
    end
  end
end
