require "application_system_test_case"

class ImportNoteFlowsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  def setup
    @user = users(:user_1)
    @file = file_fixture("notes.csv")
  end

  test "should import notes" do
    @user.notes.destroy_all
    sign_in @user
    visit root_path
    find_link("Import Notes").click
    attach_file("file", @file.open.path)
    find_button("Import Notes").click
    imported_notes_count = @file.readlines.size - 1
    assert_equal imported_notes_count, all("table tbody tr").count
  end

end
