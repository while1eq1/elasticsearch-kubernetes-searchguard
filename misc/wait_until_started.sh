#!/bin/bash
RET=1

http="http"
if [ $SEARCHGUARD_SSL_HTTP_ENABLED = true ]; then
  http="https"
fi

while [[ RET -ne 0 ]]; do
    echo "Waiting for Elasticsearch to become ready before running sgadmin..."
    curl -XGET -k "$http://localhost:9200/" >/dev/null 2>&1
    RET=$?
    sleep 5
done
