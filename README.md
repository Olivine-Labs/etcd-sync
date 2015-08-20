# etcd-sync

## Configuration
Configuration is done via ENV variables:
* `ETCD_SOURCE` - URL of source Etcd server (defaults to `http://127.0.0.1:2379`)
* `ETCD_DESTINATION` - URL of destination Etcd server (defaults to `http://127.0.0.1:2379`)
* `KEY` - starting point from which to sync (defaults to `/`)

## Running in Docker
A prebuild image is provided in the Docker Hub: [olivinelabs/etcd-sync](https://hub.docker.com/r/olivinelabs/etcd-sync/)
```
docker run -d \
  -e ETCD_SOURCE="http://<source>:2379" \
  -e ETCD_DESTINATION="http://<dest>:2379" \
  olivinelabs/etcd-sync
```

## Running locally
You need lua 5.1 and luarocks
```
luarocks make
ETCD_SOURCE="<source>" ETCD_DESTINATION="<dest>" KEY="/" lua etcd-sync/init.lua
```
