require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(email: "user@example.com", password: 'password', password_confirmation: 'password', confirmed_at: Time.zone.now)
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "should destroy associated notes" do
    @user.save!
    5.times do |n|
      @note = @user.notes.build(title: "title #{n}", body: "body #{n}")
      assert @note.valid?
      @note.save!
    end
    assert_equal @user.reload.notes.length, 5
    notes_count = @user.reload.notes.length
    assert_difference('Note.count', -"#{notes_count}".to_i) do
      @user.destroy
    end
  end

  test "notes_limit should have a deafult value of 1000" do
    @user.save!
    assert_equal @user.notes_limit, 500
  end

end
