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
    click_link 'My Notes'
    visit notes_path
    page.assert_selector('table tbody tr', count: 25)
    click_link '2'
    page.assert_selector('table tbody tr', count: 25)
    click_link 'First'
    page.assert_selector('table tbody tr', count: 25)
    click_link 'Last'
    page.assert_selector('table tbody tr', count: 25)
  end

  test "should pin notes" do
    @user.notes.destroy_all
    pinned_note_title = 'Pinned Note'
    1.upto(50) do |i|
      if(i == 1)
        @note = Note.new(title: pinned_note_title, body: Faker::Lorem.paragraph, tag_list: Faker::Lorem.words(number: 4), user: @user, pinned: true)
      else
        @note = Note.new(title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph, tag_list: Faker::Lorem.words(number: 4), user: @user)
      end
      assert @note.valid?
      @note.save!
    end
    sign_in @user
    visit root_path
    sleep 2
    click_link 'My Notes'
    sleep 2
    assert_equal page.find('table tbody tr:first-child td:first-child').text, pinned_note_title
  end

  test "should create note" do
    sign_in @user
    visit root_path
    click_link 'Create a new note'
    sleep 2
    find('#note_title').set('Note Title')
    find('#note_body').set('Note Body')
    check('Pinned')
    check('Public')
    find('.tagify__input').set('Tag 1, Tag 2')
    click_button 'Create Note'
    sleep 2
    page.assert_selector('tags tag', count: 2)
    assert_selector 'div', text: 'Note added'
    assert_equal page.find_field('Title').value, 'Note Title'
    assert_equal page.find_field('Body').value, 'Note Body'
    assert_selector 'tag:first-of-type .tagify__tag-text', text: 'tag 1'
    assert_selector 'tag:nth-child(2) .tagify__tag-text', text: 'tag 2'
  end

  test "should save even if there are no tags" do
    sign_in @user
    visit root_path
    click_link 'Create a new note'
    sleep 2
    find('#note_title').set('Note Title')
    find('#note_body').set('Note Body')
    click_button 'Create Note'
    sleep 2
    page.assert_selector('tags tag', count: 0)
  end

  test "should update note" do
    @note = @user.notes.create(title: 'Note Title', body: 'Note Body')
    @note.tag_list.add('one', 'two')
    @note.save!
    sign_in @user
    visit edit_note_path(@note)
    fill_in 'Title', with: 'Updated Title'
    fill_in 'Body', with: 'Updated Body'
    tag = find('tag:first-of-type .tagify__tag-text').double_click
    tag.send_keys(:backspace, :backspace, :backspace, 'three')
    sleep 2
    find('tag:nth-child(2) .tagify__tag__removeBtn').click
    sleep 2
    click_button 'Update Note'
    sleep 2
    assert_equal page.find_field('Title').value, 'Updated Title'
    assert_equal page.find_field('Body').value, 'Updated Body'
    assert_selector 'tag:first-of-type .tagify__tag-text', text: 'three'
    page.assert_selector('tags tag', count: 1)
  end

  test "should delete note" do
    sign_in @user
    visit edit_note_path(@user.notes.last)
    assert_difference('Note.count', -1) do
      accept_alert do
        click_link 'Delete Note'
      end
      sleep 2
    end
    assert_selector 'div', text: 'Note deleted'
  end
  
  test "should display errors during validation" do
    sign_in @user
    visit new_note_path
    click_button 'Create Note'
    assert_selector '#error_explanation'
  end

  test "should display a list of note versions and revert note" do
    @user.notes.destroy_all
    with_versioning do
      @note = Note.create(title: 'v1', body: 'v1', user: @user)
      sign_in @user
      visit edit_note_path(@note)
      click_link 'See Previous Versions'
      click_link('your note')
      2.upto(10) do |i|
        @note.update(title: "v#{i}", body: "v#{i}")
      end
      visit root_path
      click_link 'My Notes'
      sleep 2
      click_link 'Edit'
      sleep 2
      click_link 'See Previous Versions'
      sleep 2
      page.assert_selector('a', text: 'Preview', count: 9)
      first('a', text: 'Preview').click
      sleep 2
      assert_selector 'h1', text: 'v1'
      click_link('Revert to this version')
      sleep 2
      assert_equal page.find_field('Title').value, 'v1'
      assert_equal page.find_field('Body').value, 'v1'
    end
  end
  
  test "should display a list of deleted notes and restore a note" do
    @user.notes.destroy_all
    with_versioning do
      @note = Note.create(title: 'v1', body: 'v1', user: @user)
      sign_in @user
      visit root_path
      sleep 2
      click_link 'Deleted Notes'
      sleep 2
      click_link 'your notes'
      sleep 2
      @note.destroy!
      click_link 'Deleted Notes'
      sleep 2
      assert_difference('Note.count') do
        click_link 'Restore Note'
        sleep 2
      end
      assert_equal page.find_field('Title').value, 'v1'
      assert_equal page.find_field('Body').value, 'v1'
    end
  end
  
  test "should search notes" do
    @user.notes.destroy_all
    sign_in @user
    visit notes_path
    sleep 2
    page.assert_selector('a', text: 'Add your first note')
    1.upto(10) do |n|
      @note = @user.notes.build(title: "title-#{n}", body: "body-#{n}", pinned: "#{true if n == 5}" , public: "#{true if n == 2}")
      @note.tag_list.add("tag","tag-#{n}")
      @note.save!
    end
    visit root_path
    sleep 2
    visit notes_path
    sleep 2
    fill_in 'Title contains', with: 'title'
    click_button 'Search'
    sleep 2
    page.assert_selector('table tbody tr', count: 10)
    click_link 'Reset'
    sleep 2
    fill_in 'Body contains', with: 'body-1'
    click_button 'Search'
    sleep 2
    page.assert_selector('table tbody tr', count: 2)
    check 'tag-1'
    click_button 'Search'
    sleep 2
    page.assert_selector('table tbody tr', count: 1)
    fill_in 'Body contains', with: 'not gonna work'
    click_button 'Search'
    sleep 2
    page.assert_selector('table tbody tr', count: 0)
    page.assert_selector('p', text: 'Sorry, no notes match your search.')
    click_link 'Reset'
    sleep 2
    check 'Pinned?'
    click_button 'Search'
    sleep 2
    page.assert_selector('table tbody tr', count: 1)
    sleep 2
    click_link 'Reset'
    sleep 2
    check 'Public?'
    click_button 'Search'
    sleep 2
    page.assert_selector('table tbody tr', count: 1)
  end

  test "should link tags to filtered search page" do
    @user.notes.destroy_all
    @note = @user.notes.build(title: 'Note with tags', body: 'Note with tags')
    @note.tag_list.add('tag-one','tag-two','tag-three')
    @note.save!
    sign_in @user
    visit notes_path
    sleep 2
    click_link 'Preview'
    sleep 2
    click_link 'tag-two'
    sleep 2
    page.assert_selector('table tbody tr', count: 1)
  end

  test "should parse markdown" do
    @user.notes.destroy_all
    @note = @user.notes.build(title: 'Note with markdown', body: '## Markdown')
    @note.save!
    sign_in @user
    visit note_path(@note)
    sleep 2
    assert_selector 'h2', text: 'Markdown'
  end

  test "should propt user to save when clicking the view link on the edit page" do
    sign_in @user
    visit edit_note_path(@user.notes.last)
    accept_alert do
      click_link 'View Note'
      sleep 2
    end
    assert_selector 'h1', text: @user.notes.last.title
  end

  test "should display a share link if note is public" do
    sign_in @user
    @user.notes.destroy_all
    @note = @user.notes.build(title: 'Public Note', body: Faker::Lorem.paragraphs.join)
    @note.save!
    visit edit_note_path(@note)
    sleep 2
    page.assert_selector('#js-clipboard-source', count: 0)
    @note.update(public: true)
    visit edit_note_path(@note)
    sleep 2
    click_button 'Copy to clipboard.'
    sleep 2
    assert_match page.find('#js-clipboard-source').value.split('/').last, @note.slug
    visit note_path(@note)
    sleep 2
    click_button 'Copy to clipboard.'
    assert_match page.find('#js-clipboard-source').value.split('/').last, @note.slug
  end
end