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
    keys, lastIndex = util.flatten(data.action, data.node)
    for _, o in pairs(keys) do
      local actions = {
        delete = function()
          local code, data = http.put(
            destinationURL..'/v2/keys'..o.key,
            o.value
          )
          if code >= 300 or code < 200 then
            error('Error during DELETE to destination: '..json.encode(data))
          end
        end,
        set = function()
          local code, data = http.put(
            destinationURL..'/v2/keys'..o.key,
            o.value
          )
          if code >= 300 or code < 200 then
            error('Error during PUT to destination: '..json.encode(data))
          end
        end
      }
      -- TODO: Implement these properly? Maybe?
      actions.get = actions.set
      actions.update = actions.set
      actions.create = actions.set
      actions.expire = actions.delete
      local action = actions[o.action]
      if not action then
        error('Unknown action '..o.action..' for key '..o.key)
      else
        action()
      end
    end

  elseif code == 400 then
    if data.index then
      return data.index
    end
    print('Failed to get etcd changes with code '..tostring(code)..json.encode(data))
  else
    print('failed to get etcd changes with code ', tostring(code), json.encode(data))
  end
  return lastIndex
end

function o.serve(sourceURL, destinationURL, rootKey)
  local lastIndex
  while true do
    lastIndex = o.getUpdates(util.http, sourceURL, destinationURL, rootKey, lastIndex)
    if not lastIndex then util.sleep(1) else lastIndex = lastIndex + 1 end
    print(lastIndex)
  end
end

return o
