#!/bin/bash

RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake redmine:plugins:migrate
rm -f /usr/src/redmine/plugins/post-install.sh

