#!/bin/bash

# Intall plugins' ruby dependencies (Gemfile):
(cd /usr/src/redmine/plugins &&
for d in */; do
    (cd "$d" && test -f Gemfile && (bundle install2 || exit -1));
done)

# Modification de droits d'accès spécialement pour 
# le plugin CKEditor, ce répertoire étant mappé 
# depuis le répertoire data:
chown redmine /usr/src/redmine/public/system/rich

RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake redmine:plugins:migrate

