require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_1)
    @another_user = users(:user_2)
  end

  test "should get index if authenticated" do
    sign_in @user
    get notes_path
    assert_response :success
  end

  test "should not get index if not authenticated" do
    get notes_path
    assert_redirected_to new_user_session_path
  end

  test "should get show if current user owns the note" do
    sign_in @user
    get note_path(@user.notes.first)
    assert_response :success
  end

  test "should not get show if current user does not own the note" do
    get note_path(@another_user.notes.first)
    user_not_authorized
  end

  test "should get show if note is set to public" do
    @note = @user.notes.first
    @note.update(public: true)
    assert @note.public
    get note_path(@note)
    assert_response :success
  end

  test "should not get show if note is not set to public" do
    @note = @user.notes.first
    assert_not @note.public
    get note_path(@note)
    user_not_authorized
  end

  test "should get new if authenticated" do
    sign_in @user
    get new_note_path
    assert_response :success
    sign_out @user
    get new_note_path
    assert_redirected_to new_user_session_path
  end

  test "should get edit if authenticated and current user owns the note" do
    sign_in @user
    get edit_note_path(@user.notes.first)
    assert_response :success
    get note_path(@another_user.notes.first)
    user_not_authorized
  end

  test "should not get edit if not authenticated" do
    get edit_note_path(@user.notes.first)
    assert_redirected_to new_user_session_path
  end

  test "should not edit if authenticated and current user does not own the note" do 
    sign_in @user
    get note_path(@another_user.notes.first)
    user_not_authorized
  end

  test "should create note if authenticated" do
    sign_in @user
    assert_difference('Note.count', 1) do
      post notes_path, params: { note: { title: 'a new note title', body: 'a new note body', user: @user } }
    end
    assert_redirected_to edit_note_path(@user.notes.last)
    follow_redirect!
    assert_match 'Note added', @response.body
  end

  test "should not create note if not authenticated" do
    assert_no_difference('Note.count', 1) do
      post notes_path, params: { note: { title: 'a new note title', body: 'a new note body', user: @user } }
    end
    assert_redirected_to new_user_session_path
  end

  test "should render new note if authenticated but note is invalid" do
    sign_in @user
    assert_no_difference('Note.count') do
      post notes_path, params: { note: { body: nil } }
    end
    assert_equal 'create', @controller.action_name
  end

  test "should update note if authenticated and current user owns the note" do
    sign_in @user
    updated_title = 'updated title'
    get edit_note_path(@user.notes.first)
    put note_path(@user.notes.first), params: { note: { title: updated_title  } }
    assert_equal @user.notes.first.title, updated_title
    assert_redirected_to edit_note_path(@user.notes.first)
    follow_redirect!
    assert_match 'Note updated', @response.body
  end 

  test "should not update note if not authenticated" do
    updated_title = 'updated title'
    get edit_note_path(@user.notes.first)
    put note_path(@user.notes.first), params: { note: { title: updated_title  } }
    assert_not_equal @user.notes.first.title, updated_title
    assert_redirected_to new_user_session_path
  end

  test "should not update note if authenticated and current user does not own the note" do
    sign_in @user
    updated_title = 'updated title'
    get edit_note_path(@user.notes.first)
    put note_path(@another_user.notes.first), params: { note: { title: updated_title  } }
    assert_not_equal @user.notes.first.title, updated_title
    user_not_authorized
  end   
  
  test "should destroy note if authenticated and current user owns the note" do
    sign_in @user
    assert_difference('Note.count', -1) do
      delete note_path(@user.notes.last)
    end
    assert_redirected_to notes_path
    follow_redirect!
    assert_match 'Note deleted', @response.body
  end 

  test "should not destroy note if not authenticated" do
    assert_no_difference('Note.count') do
      delete note_path(@user.notes.last)
    end
    assert_redirected_to new_user_session_path
  end

  test "should not destroy note if authenticated and current user does not own the note" do
    sign_in @user
    assert_no_difference('Note.count') do
      delete note_path(@another_user.notes.last)
    end
    user_not_authorized
  end   
end
