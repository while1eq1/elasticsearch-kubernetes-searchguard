#!/bin/bash

chmod +x /elasticsearch/plugins/search-guard-6/tools/sgadmin.sh
/elasticsearch/plugins/search-guard-6/tools/sgadmin.sh \
-cd /elasticsearch/config/ \
-ks /elasticsearch/config/certs/sgadmin-keystore.jks \
-ts /elasticsearch/config/certs/truststore.jks \
-icl \
-kspass changeit \
-tspass changeit \
-h localhost \
-nhnv