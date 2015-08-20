local env = os.getenv
local server = require 'etcd-sync.server'

server.serve(
  env('ETCD_SOURCE')      or 'http://127.0.0.1:2379',
  env('ETCD_DESTINATION') or 'http://127.0.0.1:2379',
  env('KEY')              or '/'
)
