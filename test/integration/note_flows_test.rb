require 'test_helper'

class NoteFlowsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_1)
    @note = @user.notes.create(title: "Note Title", body: "Note Body")
  end

  test "should not display tags for anonymous users" do
    @note.update(public: true)
    @note.tag_list.add("tag 1", "tag 2")
    @note.save
    get note_path(@note)
    @note.tag_list.each do |tag|
      assert_select "a", text: tag, count: 0
    end
  end

  test "should  display tags for record owner" do
    sign_in @user
    @note.update(public: true)
    @note.tag_list.add("tag 1", "tag 2")
    @note.save
    get note_path(@note)
    @note.tag_list.each do |tag|
      assert_select "a", text: tag, count: 1
    end
  end

end
