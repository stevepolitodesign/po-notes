require "test_helper"

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
    assert_difference("Note.count", 1) do
      post notes_path, params: {note: {title: "a new note title", body: "a new note body", user: @user}}
    end
    assert_redirected_to edit_note_path(@user.notes.first)
    follow_redirect!
    assert_match "Note added", @response.body
  end

  test "should not create note if not authenticated" do
    assert_no_difference("Note.count", 1) do
      post notes_path, params: {note: {title: "a new note title", body: "a new note body", user: @user}}
    end
    assert_redirected_to new_user_session_path
  end

  test "should render new note if authenticated but note is invalid" do
    sign_in @user
    assert_no_difference("Note.count") do
      post notes_path, params: {note: {body: nil}}
    end
    assert_equal "create", @controller.action_name
  end

  test "should update note if authenticated and current user owns the note" do
    sign_in @user
    updated_title = "updated title"
    get edit_note_path(@user.notes.first)
    put note_path(@user.notes.first), params: {note: {title: updated_title}}
    assert_equal @user.notes.first.title, updated_title
    assert_redirected_to edit_note_path(@user.notes.first)
    follow_redirect!
    assert_match "Note updated", @response.body
  end

  test "should not update note if not authenticated" do
    updated_title = "updated title"
    get edit_note_path(@user.notes.first)
    put note_path(@user.notes.first), params: {note: {title: updated_title}}
    assert_not_equal @user.notes.first.title, updated_title
    assert_redirected_to new_user_session_path
  end

  test "should not update note if authenticated and current user does not own the note" do
    sign_in @user
    updated_title = "updated title"
    get edit_note_path(@user.notes.first)
    put note_path(@another_user.notes.first), params: {note: {title: updated_title}}
    assert_not_equal @user.notes.first.title, updated_title
    user_not_authorized
  end

  test "should destroy note if authenticated and current user owns the note" do
    sign_in @user
    assert_difference("Note.count", -1) do
      delete note_path(@user.notes.last)
    end
    assert_redirected_to notes_path
    follow_redirect!
    assert_match "Note deleted", @response.body
  end

  test "should not destroy note if not authenticated" do
    assert_no_difference("Note.count") do
      delete note_path(@user.notes.last)
    end
    assert_redirected_to new_user_session_path
  end

  test "should not destroy note if authenticated and current user does not own the note" do
    sign_in @user
    assert_no_difference("Note.count") do
      delete note_path(@another_user.notes.last)
    end
    user_not_authorized
  end

  test "should get versions if authenticed" do
    sign_in @user
    @note = @user.notes.last
    get note_versions_path(@note)
    assert_response :success
  end

  test "should not get versions if not authenticed" do
    @note = @user.notes.last
    get note_versions_path(@note)
    assert_redirected_to new_user_session_path
  end

  test "should not get versions if current user does not own note" do
    sign_in @user
    @note = @another_user.notes.last
    get note_versions_path(@note)
    user_not_authorized
  end

  test "should get version if authenticed" do
    sign_in @user
    @note = @user.notes.last
    with_versioning do
      @note.update(title: "v2", body: "v2")
      @version = @note.versions.last
      get note_version_path(@note, @version)
      assert_response :success
    end
  end

  test "should not get version if not authenticed" do
    @note = @user.notes.last
    with_versioning do
      @note.update(title: "v2", body: "v2")
      @version = @note.versions.last
      get note_version_path(@note, @version)
      assert_redirected_to new_user_session_path
    end
  end

  test "should not get version if current user does not own note" do
    sign_in @user
    @note = @another_user.notes.last
    with_versioning do
      @note.update(title: "v2", body: "v2")
      @version = @note.versions.last
      get note_version_path(@note, @version)
      user_not_authorized
    end
  end

  test "should post revert if authenticed" do
    sign_in @user
    @user.notes.destroy_all
    @note = Note.create(title: "v1", body: "v1", user: @user)
    with_versioning do
      @note.update(title: "v2", body: "v2")
      @version = @note.versions.last
      post note_revert_path(@note, @version)
      assert_equal @note.reload.title, "v1"
      assert_equal @note.reload.body, "v1"
    end
  end

  test "should not post revert if not authenticed" do
    @user.notes.destroy_all
    @note = Note.create(title: "v1", body: "v1", user: @user)
    with_versioning do
      @note.update(title: "v2", body: "v2")
      @version = @note.versions.last
      post note_revert_path(@note, @version)
      assert_redirected_to new_user_session_path
    end
  end

  test "should not post revert if current user does not own note" do
    sign_in @user
    @user.notes.destroy_all
    @note = Note.create(title: "v1", body: "v1", user: @another_user)
    with_versioning do
      @note.update(title: "v2", body: "v2")
      @version = @note.versions.last
      post note_revert_path(@note, @version)
      user_not_authorized
    end
  end

  test "should post restore if authenticed" do
    @user.notes.destroy_all
    sign_in @user
    get deleted_notes_path
    assert_response :success
    with_versioning do
      @note = Note.create(title: "v1", body: "v1", user: @user, slug: "123abc")
      Note.update(title: "v2", body: "v2", user: @user)
      assert_equal @note.versions.count, 2
      @note.destroy
      assert_difference("Note.count", 1) do
        @deleted_note = PaperTrail::Version.where(item_type: "Note", event: "destroy").where_object(user_id: @user.id).last
        post restore_note_path(@deleted_note.reify.id)
        assert_redirected_to edit_note_path(@deleted_note.reify.slug)
        follow_redirect!
        assert_match "Note restored", response.body
      end
    end
  end

  test "should not post restore if not authenticed" do
    @user.notes.destroy_all
    with_versioning do
      @note = Note.create(title: "v1", body: "v1", user: @user)
      Note.update(title: "v2", body: "v2", user: @user)
      assert_equal @note.versions.count, 2
      @note.destroy
      assert_no_difference("Note.count") do
        @deleted_note = PaperTrail::Version.where(item_type: "Note", event: "destroy").where_object(user_id: @user.id).first
        post restore_note_path(@deleted_note.reify.id)
        assert_redirected_to new_user_session_path
      end
    end
  end

  test "should not post restore if current user does not own note" do
    @user.notes.destroy_all
    sign_in @user
    with_versioning do
      @note = Note.create(title: "v1", body: "v1", user: @another_user)
      Note.update(title: "v2", body: "v2", user: @another_user)
      assert_equal @note.versions.count, 2
      @note.destroy
      assert_no_difference("Note.count") do
        @deleted_note = PaperTrail::Version.where(item_type: "Note", event: "destroy").where_object(user_id: @another_user.id).first
        post restore_note_path(@deleted_note.reify.id)
        user_not_authorized
      end
    end
  end

  test "should use hashid in path" do
    sign_in @user
    @note = Note.create(title: "Title", body: "Body", user: @user)
    assert_not_nil @note.reload.hashid
    get note_path(@note)
    assert_routing "/notes/#{@note.hashid}", controller: "notes", action: "show", id: @note.reload.hashid
  end

  test "should only display tags associated with user's notes in search form" do
    @user.notes.destroy_all
    @another_user.notes.destroy_all
    tags_name = "tag_for_user"
    @note = Note.create(title: "#{@user.email} note title ", body: "#{@user.email} note body", user: @user)
    @note.tag_list.add(tags_name)
    @note.save!
    @another_users_note = Note.create(title: "#{@another_user.email} note title ", body: "#{@another_user.email} note body", user: @another_users_note)
    sign_in @user
    get notes_path
    assert_select "label", text: tags_name
    sign_out @user
    sign_in @another_user
    get notes_path
    assert_select "label", text: tags_name, count: 0
  end
end
