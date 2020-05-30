require "test_helper"

class ExportNotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_1)
  end

  test "should get index if authenticated" do
    sign_in @user
    get export_notes_path
    assert_response :success
  end

  test "should repond with a csv" do
    sign_in @user
    get export_notes_path
    assert @response.request.format.csv?
  end

  test "should not get index if anonymous" do
    get export_notes_path
    assert_redirected_to new_user_session_path
  end
end
