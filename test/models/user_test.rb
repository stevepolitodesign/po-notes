# TODO write tests
require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:user_with_notes)
  end

  test "should destroy associated notes" do
    notes_count = @user.notes.length
    assert_difference('Note.count', -"#{notes_count}".to_i) do
      @user.destroy
    end
  end

end
