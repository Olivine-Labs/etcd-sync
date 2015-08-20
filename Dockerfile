FROM ubuntu:14.04
MAINTAINER Drew Ditthardt <dditthardt@olivinelabs.com>

ENV ETCD_SOURCE "http://127.0.0.1:2379"
ENV ETCD_DESTINATION "http://127.0.0.1:2379"
ENV KEY "/"

RUN apt-get update && apt-get upgrade -y && apt-get install -y lua5.1 luarocks lua-sec

ADD . /tmp/
RUN cd /tmp && luarocks make

ENTRYPOINT cd /tmp && lua etcd-sync/init.lua
