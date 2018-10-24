FROM alpine:3.8
LABEL maintainer="William Broach <while1eq1@gmail.com>"

# Install Java
ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre

RUN apk upgrade --update-cache; \
    apk add openjdk8-jre; \
    rm -rf /tmp/* /var/cache/apk/*

# Instal OpenSSL
RUN apk add --no-cache openssl

# Export HTTP & Transport
EXPOSE 9200 9300

ENV ES_VERSION 6.4.1

ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/elasticsearch"
ENV ES_TARBAL "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz"
ENV ES_TARBALL_ASC "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz.asc"
ENV GPG_KEY "46095ACC8548582C1A2699A9D27D666CD88E42B4"

# Install Elasticsearch.
RUN apk add --no-cache --update bash ca-certificates su-exec util-linux curl
RUN apk add --no-cache -t .build-deps gnupg openssl \
    && cd /tmp \
    && echo "===> Install Elasticsearch..." \
    && curl -o elasticsearch.tar.gz -Lskj "$ES_TARBAL"; \
    if [ "$ES_TARBALL_ASC" ]; then \
    curl -o elasticsearch.tar.gz.asc -Lskj "$ES_TARBALL_ASC"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY"; \
    gpg --batch --verify elasticsearch.tar.gz.asc elasticsearch.tar.gz; \
    rm -r "$GNUPGHOME" elasticsearch.tar.gz.asc; \
    fi; \
    tar -xf elasticsearch.tar.gz \
    && ls -lah \
    && mv elasticsearch-$ES_VERSION /elasticsearch \
    && adduser -DH -s /sbin/nologin elasticsearch \
    && echo "===> Creating Elasticsearch Paths..." \
    && for path in \
    /elasticsearch/config \
    /elasticsearch/config/scripts \
    /elasticsearch/plugins \
    ; do \
    mkdir -p "$path"; \
    chown -R elasticsearch:elasticsearch "$path"; \
    done \
    && rm -rf /tmp/* \
    && apk del --purge .build-deps

# Set environment variables defaults
ENV ES_JAVA_OPTS "-Xms512m -Xmx512m"
ENV ES_TMPDIR="/tmp"
ENV CLUSTER_NAME elasticsearch-default
ENV NODE_NAME=""
ENV NODE_MASTER true
ENV NODE_DATA true
ENV NODE_INGEST true
ENV HTTP_ENABLE true
ENV NETWORK_HOST _site_
ENV HTTP_CORS_ENABLE true
ENV HTTP_CORS_ALLOW_ORIGIN *
ENV NUMBER_OF_MASTERS 2
ENV MAX_LOCAL_STORAGE_NODES 1
ENV SHARD_ALLOCATION_AWARENESS ""
ENV SHARD_ALLOCATION_AWARENESS_ATTR ""
ENV MEMORY_LOCK false
ENV REPO_LOCATIONS ""
ENV DISCOVERY_SERVICE elasticsearch-discovery
ENV STATSD_HOST=statsd.statsd.svc.cluster.local
ENV SEARCHGUARD_SSL_HTTP_ENABLED true
ENV SEARCHGUARD_SSL_TRANSPORT_ENABLED true

ENV PATH /elasticsearch/bin:$PATH
WORKDIR /elasticsearch

# Copy configuration
COPY config /elasticsearch/config

# Copy run scripts
COPY /misc/sgadmin.sh /
COPY /misc/wait_until_started.sh /
COPY run.sh /

# Install search-guard-6
RUN ./bin/elasticsearch-plugin install -b com.floragunn:search-guard-6:6.4.1-23.1

# Install s3 repository plugin
RUN ./bin/elasticsearch-plugin install repository-s3 --batch

# Install prometheus plugin
RUN ./bin/elasticsearch-plugin install --batch https://github.com/vvanholl/elasticsearch-prometheus-exporter/releases/download/6.4.1.0/elasticsearch-prometheus-exporter-6.4.1.0.zip

# Volume for Elasticsearch data
VOLUME ["/data"]

CMD ["/run.sh"]


