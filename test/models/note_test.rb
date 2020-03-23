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
    @pinned_note = Note.new(title: "pinned note", body: "pinned note body", user: @user, pinned: true)
    assert @note.valid?
    @pinned_note.save!
    1.upto(10) do |i|
      @note = Note.new(title: "note-title-#{i}", body: "note-body-#{i}", user: @user)
      assert @note.valid?
      @note.save!
    end
    assert_equal @pinned_note.title, @user.notes.reload.first.title
    assert_equal "note-title-10", @user.notes.reload.second.title
  end

  test "should set hashid" do
    assert_nil @note.hashid
    @note.save!
    assert_not_nil @note.hashid
  end

  test "should not change hashid on update" do
    @note.save!
    original_hashid = @note.hashid
    @note.update(title: 'hashid should not update')
    assert_equal original_hashid, @note.reload.hashid
  end

  test "should use user_id as a slug candidate" do
    @note.save!
    @note_with_duplicate_hashid =  @user.notes.build(title: "Duplicate hashid", body: "Duplicate hashid", hashid: @note.reload.hashid)
    @note_with_duplicate_hashid.save!
    assert_equal @note_with_duplicate_hashid.reload.slug.split("-").last.to_i, @note_with_duplicate_hashid.user_id
  end

  test "should not create duplicate tags" do
    @note.tag_list.add('one', 'One', 'oNe', 'Two', 'two')
    @note.save!
    assert_equal @note.reload.tag_list, ["one", "two"]
  end

  test "should lowercase tags" do
    @note.tag_list.add('ONE')
    @note.save!
    assert_equal @note.reload.tag_list, ["one"]
  end

  test "should parse tag list" do
    @note.tag_list.add('[{"value":"one"}','{"value":"two"}]')
    @note.save!
    assert_equal @note.reload.tag_list, ["one", "two"]
  end

  test "should limit notes created to the user's notes_limit" do
    @user.notes.destroy_all
    500.times do |n|
      @note = @user.notes.build(title: "title #{n}", body: "body #{n}")
      assert @note.valid?
      @note.save!
    end
    assert_equal @user.reload.notes.count, 500
    @note = @user.notes.build(title: "Note 501", body: "Note 501")
    assert_not @note.valid?
    assert_equal @note.errors.messages[:user_id][0], "has reached their note limit"
  end

  test "should not limit notes created if user's notes_limit is nil" do
    @user.update(notes_limit: nil)
    @user.save!
    assert_nil @user.reload.notes_limit
    1.upto(2) do |i|
      assert_difference('Note.count') do
        @note = @user.notes.build(title: "Note #{i}", body: "Note Body #{i}")
        assert @note.valid?
        @note.save
      end
    end    
  end
end
