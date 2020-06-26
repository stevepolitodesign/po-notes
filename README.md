# PoNotes

An application to help take notes, complete tasks and set reminders.

# Initial Setup

```
bundle install
yarn
rails db:setup
```

# Credentials

`rails credentials:edit`

```
twilio:
  account_sid: 123abc
  auth_token: 456def
  number: +11234567890 ()
  test_number: verified caller id
```

# Local Development

```
foreman start
```

# To-Dos

```
rails notes TODO
```

# Tests

Using the default [Rails testing framework](https://guides.rubyonrails.org/testing.html#rails-meets-minitest).

```
rails t
rails test:system
```

# Formatting

Using [standard](https://github.com/testdouble/standard).

```
standardrb --fix
```
