require 'test_helper'

class ImportNotesJobTest < ActiveJob::TestCase
  def setup
    @user = users(:user_1)
    @file
  end

  test "should import notes" do
    assert_difference("Note.count") do
      ImportNotesJob.perform_now(@file, @user)
    end
  end
  
end
