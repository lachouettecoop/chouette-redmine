#!/bin/bash

# Intall plugins' ruby dependencies (Gemfile):
(cd /usr/src/redmine/plugins &&
for d in */; do
    cd "$d" && test -f Gemfile && bundle install;
done)

RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake redmine:plugins:migrate

