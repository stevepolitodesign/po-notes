require "test_helper"

class NoteImportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  def setup
    @user = users(:user_1)
    @file = file_fixture("notes.csv")
  end

  test "should post to create if authenticated" do
    sign_in @user
    post import_notes_path, params: {file: fixture_file_upload(@file.open.path)}
    assert_redirected_to notes_path
  end

  test "should not post to create if anonymous" do
    post import_notes_path, params: {file: fixture_file_upload(@file.open.path)}
    assert_redirected_to new_user_session_path
  end

  test "should get new if authenticated" do
    sign_in @user
    get import_notes_path
    assert_response :success
  end

  test "should not get new if anonymous" do
    get import_notes_path
    assert_redirected_to new_user_session_path
  end

  test "should import notes on create" do
    @user.notes.destroy_all
    sign_in @user
    assert_difference("Note.count", @file.readlines.size - 1) do
      post import_notes_path, params: {file: fixture_file_upload(@file)}
    end
  end

  test "should handle invalid file types when posting to create" do
    sign_in @user
    post import_notes_path, params: {file: fixture_file_upload(file_fixture("notes.txt").open.path)}
    assert_redirected_to import_notes_path
  end
end
