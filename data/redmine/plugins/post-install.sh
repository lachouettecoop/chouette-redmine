#!/bin/bash

set -e

# Intall plugins' ruby dependencies (Gemfile):
cd /usr/src/redmine/plugins
for d in */; do
    cd /usr/src/redmine/plugins/$d
    if test -f Gemfile ; then
        bundle install
    fi
done

cd /usr/src/redmine
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake redmine:plugins:migrate

