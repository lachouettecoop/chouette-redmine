FROM redmine:3.0.5-passenger

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libmysqlclient-dev  build-essential \
    && rm -rf /var/lib/apt/lists/*

# Apply patch so that:
# - default / page will list projects
# - listed project links will jump to their wiki page
COPY home-to-project-index.patch project-hierarchy-jump-to-wiki.patch /usr/src/redmine/
RUN cd /usr/src/redmine/ \
    && patch -p1 -E < home-to-project-index.patch \
    && patch -p1 -E < project-hierarchy-jump-to-wiki.patch 

# Installation du plugin scrum2b
# https://github.com/scrum2b/scrum2b
# Installation de version du 6 février 2017 (b853ecd86957522765a138459f59b21986a3c3c5)
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/* \
    && cd /usr/src/redmine/plugins/ \
    && git clone https://github.com/scrum2b/scrum2b.git \
    && cd scrum2b \
    && git checkout b853ecd86957522765a138459f59b21986a3c3c5 \
    && bundle install

# Installation du plugin scrum (backlog, sprint)
# http://www.redmine.org/plugins/scrum-plugin
RUN cd /usr/src/redmine/plugins/ \
    && (curl https://redmine.ociotec.com/attachments/download/440/scrum%20v0.16.2.tar.gz | tar zx)

COPY post-install.sh /usr/src/redmine/plugins/

