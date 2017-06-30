# Sample Request

rake db:seed

Einloggen: `POST /sessions`
Payload `{user: :user_id}`

Session abfragen: `/sessions/:sessionId?embed=user,permissions,features`

Jan Renz: issue key transactions

## Start account service with grr

`bundle exec rackup -r grr -s grr config.ru -o 0.0.0.0 -p 6575`

## Installation with account service

In Gemfile:

`gem 'grr', path: '/path/to/grr/'`

`bundle install` (beware of installing bcrypt manually on win with `gem install bcrypt --platform=ruby`)

`rake db:create`

`rake db:migrate`

`rake db:seed`