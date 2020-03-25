# PoNotes

An application to help take notes, complete tasks and set reminders.

---

# Local Build

```
bundle install
nvm use 12.16.1
yarn add
rails db:create
rails db:migrate
rails db:seed
```

---

# To Do

```
rails notes TODO
```

---

# Testing

Using the default [Rails testing framework](https://guides.rubyonrails.org/testing.html#rails-meets-minitest).

## Run Tests

```
rails t
```

## Run System Tests

```
rails test:system
```

---

# Formatting

Using [standard](https://github.com/testdouble/standard).

```
standardrb --fix
```

---

# Application Outline

This application is a work in progress. Below is a high level outline.

## Models

### Note

- `title:string`
  - Default value of `untitled`
- `body:text`
- `user:references`
- `tags`
- `pinned:boolean`
  - Default value of `false`
- `public:boolean`
  - Default value of `false`

#### Functionality

- Use [hash-id](https://rubygems.org/gems/hashid-rails) to create unique URLs
- Use [paper_trail](https://github.com/paper-trail-gem/paper_trail) to handle versioning and soft deletes
- Consider using [attr_encrypted](https://github.com/attr-encrypted/) for encryption
  - Note that this will mean a note cannot be searched
- Allow a `user` to share `note`
- Allow a `user` to import a `note`
- Allow a `user` to export a `note` or multiple `notes`
- Support `markdown`

---

### Task

- `title:string`
  - Default value of `untitled`
- `user:references`
- `task_item:references`
- `tags`

#### Functionality

- Should have a limit on associated `task_items`
- Drag and Drop `task_items` using [acts_as_list](https://github.com/brendon/acts_as_list) and [Sortable](https://github.com/SortableJS/Sortable)

### Task Item

- `body:string`
  - Default value of `untitled`
- `complete:boolean`
- `position:integer`
  - Use [acts_as_list](https://github.com/brendon/acts_as_list)
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
  - Needs to account for `users` timezone

#### Functionality

- Will notify user of the `reminder` on the `notify` date and time via [twilio](https://www.twilio.com/)
- Will automatically be deleted via a custom `job` once the `date` has passed

---

### User

- `phone:text`
  - Use [attr_encrypted](https://github.com/attr-encrypted/) for encryption
- `time_zone:string`
  - Default value of `UTC`
- `note_limit:integer`
  - Default value of `500`
- `reminder_limit:integer`
  - Default value of `25`
- `task_limit:integer`
  - Default value of `100`

#### Functionality

- User should be `confirmable`
- User should be able to confirm their `phone` before receiving notifications

---

## Jobs

## Export Notes

- Will export a `note` as a `.txt` or `.zip`

## Import Notes

- Will import a `note` from a `.csv` or `.txt` file

## Notify User

- Will notify a `user` via `user.phone` of a `reminder` based on the `reminder.notify` value

---

## Other Features

- Ability to search across `notes`, `tasks` and `reminders`
