FROM redmine:3.0.5-passenger

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libmysqlclient-dev  build-essential \
    && rm -rf /var/lib/apt/lists/*

# Apply patch so that:
# - default / page will list projects
# - listed project links will jump to project's wiki page
COPY home-to-project-index.patch project-hierarchy-jump-to-wiki.patch /usr/src/redmine/
RUN cd /usr/src/redmine/ \
    && patch -p1 -E < home-to-project-index.patch \
    && patch -p1 -E < project-hierarchy-jump-to-wiki.patch 

