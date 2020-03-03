require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:user_with_notes)
    @note = Note.new(title: "A note title", body: "A note body", user: @user )
  end

  test "should be valid" do
    assert @note.valid?
  end

  test "should have a user" do
    @note.user = nil
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
end
