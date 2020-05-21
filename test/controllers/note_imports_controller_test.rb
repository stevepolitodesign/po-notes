require 'test_helper'

class NoteImportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_1)
  end

  test "should post to create if authenticated" do
    sign_in @user
    post import_notes_path, params: {file: "notes.csv"}
    assert_redirected_to notes_path
  end

  test "should not post to create if anonymous" do
    post import_notes_path, params: {file: "notes.csv"}
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
end
