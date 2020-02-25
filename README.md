# PoNotes

An application to help take notes, complete tasks and set reminders.

# Application Outline

This application is a work in progress. Below is a high level outline.

## Models

### Note

- `title:string`
  - Default value of `untitled`
- `body:text`
- `user:references`
- `tags`

#### Functionality

- Use [hash-id](https://rubygems.org/gems/hashid-rails) to create unique URLs
- Use [paper_trail](https://github.com/paper-trail-gem/paper_trail) to handle versioning and soft deletes
- Consider using [attr_encrypted](https://github.com/attr-encrypted/) for encryption
  - Note that this will mean a note cannot be searched
- Allow a `user` to share `note`
- Allow a `user` to import a `note`
- Allow a `user` to export a `note`
- Support `markdown`

---

### Task

- `title:string`
  - Default value of `untitled`
- `user:references`
- `task_item:references`
- `tags`

### Task Item

- `body:string`
  - Default value of `untitled`
- `complete:boolean`
- Default value of `false`

---

### Reminder

- `title:string`
  - Default value of `untitled`
- `body:text`
- `user:references`
- `tags`
- `date:datetime`
- `notify:datetime`
  - Cannot be greater than the `date` value
  - Cannot be less than the current `datetime`

#### Functionality

- Will notify user of the `reminder` on the `notify` date and time via [twilio](https://www.twilio.com/)
- Will automatically be deleted via a custom `job` once the `date` has passed

---

### User

- `phone:text`
  - Use [attr_encrypted](https://github.com/attr-encrypted/) for encryption

#### Functionality

- User should be `confirmable`
- User should be able to confirm their `phone` before receiving notifications

---

## Jobs

## Export Notes

- Will export a `note` as a `.txt` or `zip`

## Import Notes

- Will import a `note` from a `csv` or `txt` file

## Notify User

- Will notify a `user` via `user.phone` of a `reminder` based on the `reminder.notify` value
