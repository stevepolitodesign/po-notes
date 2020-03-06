require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:user_1)
    @note = Note.new(title: "A note title", body: "A note body", user: @user )
  end

  test "should be valid" do
    assert @note.valid?
  end

  test "should have a user" do
    @note.user = nil
    assert_not @note.valid?
  end

  test "should have a body" do
    @note.body = nil
    assert_not @note.valid?
    @note.body = " "
    assert_not @note.valid?
  end

  test "can have many tags" do
    assert_equal @note.tag_list.length, 0
    @note.tag_list.add("personal", "work")
    assert_equal @note.tag_list.length, 2
  end

  test "should set a default value of 'untitled' for the title" do
    @note.title = nil
    @note.save!
    assert_equal @note.reload.title, 'Untitled'
    @note = Note.new
    assert_equal @note.title, 'Untitled'
  end

  test "should set a default value of false for pinned" do
    @note = Note.new
    assert_not @note.pinned
  end

  test "should set a default value of false for public" do
    @note = Note.new
    assert_not @note.public
  end

  test "should save versions" do
    with_versioning do
      orignal_title = @note.title
      @note.save
      assert_equal @note.versions.length, 1
      @note.update(title: 'updated title')
      assert_equal @note.versions.length, 2
      assert_equal @note.versions.last.reify.title, orignal_title
    end
  end

  test "should not save more than 10 verions" do
    with_versioning do
      @note.save
      assert_equal @note.versions.length, 1
      10.times do |n|
        @note.update(title: "version #{n}")
      end
      assert_equal @note.versions.length, 10
    end
  end

  test "should restore a deleted note" do
    with_versioning do
      @note.save
      assert_difference('Note.count', -1) do
        @note.destroy
      end
      @restored_note = Note.new(id:@note.id, user: @note.user, body: @note.body)
      assert_difference('Note.count', 1) do
        @restored_note.save
      end
    end
  end

  test "should order by last updated" do
    @user.notes.destroy_all
    1.upto(10) do |i|
      @note = Note.new(title: "note-title-#{i}", body: "note-body-#{i}", user: @user)
      assert @note.valid?
      @note.save!
    end
    assert_equal @user.notes.reload.last.title, "note-title-1"
    @user.notes.last.update(title: "update note")
    assert_equal @user.notes.reload.first.title, "update note"
  end

  test "should order pinned notes to top" do
    @user.notes.destroy_all
    1.upto(10) do |i|
      @note = Note.new(title: "note-title-#{i}", body: "note-body-#{i}", user: @user, pinned: "#{true if i === 1}")
      assert @note.valid?
      @note.save!
    end
    assert_equal "note-title-1", @user.notes.reload.first.title
    assert_equal "note-title-10", @user.notes.reload.second.title
  end  

end
