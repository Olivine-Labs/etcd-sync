package = "etcd-sync"
version = "scm-1"
source = {
  url = "",
  dir = "."
}
description = {
  summary = "",
  detailed = [[
  ]]
}
dependencies = {
  "lua >= 5.1",
  "busted >= 1.5.0",
  "lua-cjson >= 2.1.0-1",
  "luasocket >= 3.0rc1-2",
}
build = {
  type = "builtin",
  modules = {
  },
  install = {
  }
}
