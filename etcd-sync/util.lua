local socket = require 'socket'
local http = require 'socket.http'
local ltn12 = require 'ltn12'
local json = require 'cjson'

local o = {}
o.urlencode = require 'socket.url'.escape

function o.flatten(input, output, index)
  if not output then output = {} end
  if not index then index = 0 end

  local newIndex = math.max(input.createdIndex, input.modifiedIndex)
  if newIndex > index then
    index = newIndex
  end

  if input.dir then
    for _, node in pairs(input.nodes) do
      o.flatten(node, output, index)
    end
  else
    output[#output+1] = {key = input.key, value = input.value, expiration=input.expiration}
  end
  return output, index
end

o.http = {}

local function create()
  local req_sock = socket.tcp()
  req_sock:settimeout(3000)
  return req_sock
end

function o.http.get(url)
  local body = {}
  local result, code, headers, status = http.request({
    url = url,
    sink = ltn12.sink.table(body),
    method = 'GET',
    create = create,
    headers = {
      ['accept'] = 'application/json',
    },
    redirect = true,
  })
  if not tonumber(code) then
    error('Failed to GET '..url..'. Reason: '..code)
  end
  local data
  if #body > 0 then
    data = json.decode(table.concat(body))
  end

  return code, data
end

function o.http.put(url, data)
  local body = {}
  local result, code, headers, status = http.request({
    url = url,
    source = ltn12.source.string(json.encode(data)),
    sink = ltn12.sink.table(body),
    create = create,
    method = 'PUT',
    headers = {
      ['content-type'] = 'application/json',
    },
    redirect = true,
  })
  if not tonumber(code) then
    error('Failed to PUT '..url..'. Reason: '..code)
  end
  local data
  if #body > 0 then
    data = json.decode(table.concat(body))
  end
  return code, data
end

return o
