# elasticsearch-kubernetes-searchguard

Ready to use, lean Elasticsearch Docker image with SearchGuard 6 ready for using within a Kubernetes cluster.

This container is primarily for use with the elasticsearch operator - https://github.com/upmc-enterprises/elasticsearch-operator

[![Docker Repository on Quay](https://quay.io/repository/while1eq1/elasticsearch-kubernetes-searchguard/status "Docker Repository on Quay")](https://quay.io/repository/while1eq1/elasticsearch-kubernetes-searchguard)

## Current software

* Alpine Linux 3.8
* openjdk8-jre
* Elasticsearch 6.4.1

**Note:** `x-pack-ml` module is forcibly disabled as it's not supported on Alpine Linux.

## Environment variables

This image can be configured by means of environment variables, that one can set on a `Deployment`.


* [DISCOVERY_SERVICE](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-zen.html#unicast) - the service to be queried for through DNS (default = `elasticsearch-discovery`).

