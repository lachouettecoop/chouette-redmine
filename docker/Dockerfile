FROM redmine:3.0.5-passenger

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libmysqlclient-dev  build-essential \
    && rm -rf /var/lib/apt/lists/*
