local json = require 'cjson'
local util = require 'etcd-sync.util'

local o = {}

function o.getUpdates(http, sourceURL, destinationURL, rootKey, lastIndex)
  local url = {
    sourceURL,
    '/v2/keys',
    rootKey,
    '?recursive=true'
  }
  if lastIndex then
    url[#url+1] = '&wait=true&waitIndex='..tostring(lastIndex)
  end

  local code, data = http.get(table.concat(url))
  if code == 200 then
    local keys
    keys, lastIndex = util.flatten(data.node)
    for _, o in pairs(keys) do
      local code, data = http.put(
        destinationURL..'/v2/keys'..o.key,
        {o.value, o.expiration}
      )
      if code ~= 200 then
        error('Error during PUT to destination: '..json.encode(data))
      end
    end

  elseif code == 400 then
    error('Failed to get etcd changes with code '..tostring(code)..json.encode(data))
  else
    print('failed to get etcd changes with code ', tostring(code), json.encode(data))
  end
  return lastIndex
end

function o.serve(sourceURL, destinationURL, rootKey)
  local lastIndex
  while true do
    lastIndex = o.getUpdates(util.http, sourceURL, destinationURL, rootKey, lastIndex)
  end
end

return o
