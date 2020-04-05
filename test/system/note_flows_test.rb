require "application_system_test_case"

class NoteFlowsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_1)
  end

  test "should paginate user notes" do
    @user.notes.destroy_all
    assert_equal 0, @user.notes.count
    1.upto(50) do |i|
      @note = Note.new(title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph, tag_list: Faker::Lorem.words(number: 4), user: @user)
      assert @note.valid?
      @note.save!
    end
    sign_in @user
    visit root_path
    find_link("My Notes").click
    visit notes_path
    assert_equal all("table tbody tr").count, 25
    find_link("2").click
    assert_equal all("table tbody tr").count, 25
    find_link("First").click
    assert_equal all("table tbody tr").count, 25
    find_link("Last").click
    assert_equal all("table tbody tr").count, 25
  end

  test "should pin notes" do
    @user.notes.destroy_all
    pinned_note_title = "Pinned Note"
    1.upto(50) do |i|
      @note = if i == 1
        Note.new(title: pinned_note_title, body: Faker::Lorem.paragraph, tag_list: Faker::Lorem.words(number: 4), user: @user, pinned: true)
      else
        Note.new(title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph, tag_list: Faker::Lorem.words(number: 4), user: @user)
      end
      assert @note.valid?
      @note.save!
    end
    sign_in @user
    visit root_path
    find_link("My Notes").click
    assert_equal find("table tbody tr:first-child td:first-child").text, pinned_note_title
  end

  test "should create note" do
    sign_in @user
    visit root_path
    find_link("Create a new note").click
    find_field("Title").set("Note Title")
    find_field("Body").set("Note Body")
    find_field("Pinned").check
    find_field("Public").check
    find(".tagify__input").set("Tag 1, Tag 2")
    find_button("Create Note").click
    assert_equal all("tags tag").count, 2
    assert_match "Note added", find("#flash-message").text
    assert_equal find_field("Title").value, "Note Title"
    assert_equal find_field("Body").value, "Note Body"
    assert_equal find("tag:first-of-type .tagify__tag-text").text, "tag 1"
    assert_equal find("tag:nth-child(2) .tagify__tag-text").text, "tag 2"
  end

  test "should save even if there are no tags" do
    sign_in @user
    visit root_path
    find_link("Create a new note").click
    find_field("Title").set("Note Title")
    find_field("Body").set("Note Body")
    find_button("Create Note").click
    assert_equal all("tags tag").count, 0
  end

  test "should update note" do
    @note = @user.notes.create(title: "Note Title", body: "Note Body")
    @note.tag_list.add("one", "two")
    @note.save!
    sign_in @user
    visit edit_note_path(@note)
    find_field("Title").set("Updated Title")
    find_field("Body").set("Updated Body")
    tag = find("tag:first-of-type .tagify__tag-text")
    tag.double_click
    tag.send_keys(:backspace, :backspace, :backspace, "three")
    find("tag:nth-child(2) .tagify__tag__removeBtn").click
    sleep 2
    find_button("Update Note").click
    assert_equal find_field("Title").value, "Updated Title"
    assert_equal find_field("Body").value, "Updated Body"
    assert_equal "three", find("tag:first-of-type .tagify__tag-text").text
    assert_equal all("tags tag").count, 1
  end

  test "should delete note" do
    sign_in @user
    visit edit_note_path(@user.notes.last)
    assert_difference("Note.count", -1) do
      accept_alert do
        find_link("Delete Note").click
      end
      sleep 2
    end
    assert_match "Note deleted", find("#flash-message").text
  end

  test "should display errors during validation" do
    sign_in @user
    visit new_note_path
    find_button("Create Note").click
    find("#error_explanation")
  end

  test "should display a list of note versions and revert note" do
    @user.notes.destroy_all
    with_versioning do
      @note = Note.create(title: "v1", body: "v1", user: @user)
      sign_in @user
      visit edit_note_path(@note)
      find_link("See Previous Versions").click
      click_link("your note")
      2.upto(10) do |i|
        @note.update(title: "v#{i}", body: "v#{i}")
      end
      visit root_path
      find_link("My Notes").click
      find_link("Edit").click
      find_link("See Previous Versions").click
      assert_equal all("a") { |el| el.text == "Preview" }.count, 9
      first("a", text: "Preview").click
      assert_equal "v1", find("h1").text
      find_link("Revert to this version").click
      assert_equal find_field("Title").value, "v1"
      assert_equal find_field("Body").value, "v1"
    end
  end

  test "should display a list of deleted notes and restore a note" do
    @user.notes.destroy_all
    with_versioning do
      @note = Note.create(title: "v1", body: "v1", user: @user)
      sign_in @user
      visit root_path
      find_link("Deleted Notes").click
      find_link("your notes").click
      @note.destroy!
      sleep 2
      find_link("Deleted Notes").click
      assert_difference("Note.count") do
        find_link("Restore Note").click
        sleep 2
      end
      assert_equal find_field("Title").value, "v1"
      assert_equal find_field("Body").value, "v1"
    end
  end

  test "should search notes" do
    @user.notes.destroy_all
    sign_in @user
    visit notes_path
    find_link("Add your first note")
    1.upto(10) do |n|
      @note = @user.notes.build(title: "title-#{n}", body: "body-#{n}", pinned: n == 5, public: n == 5)
      @note.tag_list.add("tag", "tag-#{n}")
      @note.save!
    end
    visit root_path
    sleep 2
    visit notes_path
    find_field("Title contains").set("title")
    find_button("Search").click
    assert_equal 10, all("table tbody tr").count
    find_link("Reset").click
    sleep 2
    find_field("Body contains").set("body-1")
    find_button("Search").click
    assert_equal 2, all("table tbody tr").count
    find_field("tag-1").check
    find_button("Search").click
    assert_equal all("table tbody tr").count, 1
    find_field("Body contains").set("not gonna work")
    find_button("Search").click
    assert_equal all("table tbody tr").count, 0
    find("p") { |el| el.text == "Sorry, no notes match your search." }
    find_link("Reset").click
    sleep 2
    find_field("Pinned?").check
    find_button("Search").click
    assert_equal all("table tbody tr").count, 1
    find_link("Reset").click
    sleep 2
    find_field("Public?").check
    find_button("Search").click
    assert_equal all("table tbody tr").count, 1
  end

  test "should link tags to filtered search page" do
    @user.notes.destroy_all
    @note = @user.notes.build(title: "Note with tags", body: "Note with tags")
    @note.tag_list.add("tag-one", "tag-two", "tag-three")
    @note.save!
    sign_in @user
    visit notes_path
    find_link("Preview").click
    find_link("tag-two").click
    assert_equal 1, all("table tbody tr").count
  end

  test "should parse markdown" do
    @user.notes.destroy_all
    @note = @user.notes.build(title: "Note with markdown", body: "## Markdown")
    @note.save!
    sign_in @user
    visit note_path(@note)
    find("h2") { |el| el.text == "Markdown" }
  end

  test "should propt user to save when clicking the view link on the edit page" do
    sign_in @user
    visit edit_note_path(@user.notes.last)
    accept_alert do
      find_link("View Note").click
      sleep 2
    end
    find("h1") { |el| el.text == @user.notes.last.title }
  end

  test "should display a share link if note is public" do
    sign_in @user
    @user.notes.destroy_all
    @note = @user.notes.build(title: "Public Note", body: Faker::Lorem.paragraphs.join)
    @note.save!
    visit edit_note_path(@note)
    assert_equal 0, all("#js-clipboard-source").count
    @note.update(public: true)
    sleep 2
    visit edit_note_path(@note)
    find_button("Copy to clipboard.").click
    assert_match @note.slug, find("#js-clipboard-source").value.split("/").last
    visit note_path(@note)
    find_button("Copy to clipboard.").click
    assert_match @note.slug, find("#js-clipboard-source").value.split("/").last
  end
end
