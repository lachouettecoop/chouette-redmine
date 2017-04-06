FROM redmine:3.3.2-passenger

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libmysqlclient-dev  build-essential \
    && rm -rf /var/lib/apt/lists/*

# Installation de la commande git
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Installation de du plugin ldap_sync
# https://github.com/thorin/redmine_ldap_sync
RUN cd /usr/src/redmine/plugins/ \
    && (wget -q -O - "https://github.com/thorin/redmine_ldap_sync/archive/2.0.7.tar.gz" | tar zx) \
    && mv redmine_ldap_sync-2.0.7 redmine_ldap_sync

# Installation du plugin base_deface
# https://github.com/jbbarth/redmine_base_deface
# Installation de version du 19 Janvier 2017 (e31dd251f859081545c0e00c4af63de047fa99bc)
RUN cd /usr/src/redmine/plugins/ \
    && git clone https://github.com/jbbarth/redmine_base_deface.git \
    && cd redmine_base_deface \
    && git checkout e31dd251f859081545c0e00c4af63de047fa99bc \
    &&  (echo "source 'https://rubygems.org'" >> Gemfile) \
    && bundle install

# Installation du plugin redmine_multiprojects_issue
# https://github.com/nanego/redmine_multiprojects_issue
RUN cd /usr/src/redmine/plugins/ \
    && (wget -q -O - "https://github.com/nanego/redmine_multiprojects_issue/archive/v3.3.0.tar.gz" | tar zx) \
    && mv redmine_multiprojects_issue-3.3.0 redmine_multiprojects_issue

# Installation du plugin scrum (backlog, sprint)
# http://www.redmine.org/plugins/scrum-plugin
RUN cd /usr/src/redmine/plugins/ \
    && (wget -q -O - "https://redmine.ociotec.com/attachments/download/440/scrum%20v0.16.2.tar.gz" | tar zx)

# Apply patch so that:
# - default / page will list projects
# - listed project links will jump to their wiki page
COPY home-to-project-index.patch project-hierarchy-jump-to-wiki.patch /usr/src/redmine/
RUN cd /usr/src/redmine/ \
    && patch -p1 -E < home-to-project-index.patch \
    && patch -p1 -E < project-hierarchy-jump-to-wiki.patch 

