# PoNotes

An application to help take notes, complete tasks and set reminders.

# Initial Setup

```
bundle install
yarn
rails db:setup
```

# Credentials

## Production

`rails credentials:edit`

```
twilio:
  account_sid: ACCOUNT SID
  auth_token: AUTH TOKEN
  number: ACTIVE NUMBER
```

## Test

`rails credentials:edit --environment=test`

```
twilio:
  account_sid: TEST ACCOUNT SID
  auth_token: TEST AUTH TOKEN
  number: +15005550006 (https://www.twilio.com/blog/2018/04/twilio-test-credentials-magic-numbers.html)
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
