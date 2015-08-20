local socket = require 'socket'
local http = require 'socket.http'
local ltn12 = require 'ltn12'
local json = require 'cjson'

local o = {}
o.urlencode = require 'socket.url'.escape

function o.sleep(sec)
  socket.select(nil, nil, sec)
end

function o.flatten(action, input, output, index)
  if not output then output = {} end

  local newIndex = (input.createdIndex or input.modifiedIndex) and math.max(input.createdIndex or 0, input.modifiedIndex or 0) or nil
  if newIndex and newIndex > (index or 0) then
    index = newIndex
  end

  if input.dir and input.nodes then
    for _, node in pairs(input.nodes) do
      local _
      _, index = o.flatten(input.action or action, node, output, index)
    end
  elseif input.value then
    output[#output+1] = {key = input.key, value = input.value, expiration=input.expiration, action=action}
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
    print(table.concat(body))
    data = json.decode(table.concat(body))
  end

  return code, data
end

function o.http.put(url, data)
  local input
  for k, v in pairs(data) do
    if not input then
      input = ''
    else
      input = input..'&'
    end
    input = input..k..'='..o.urlencode(tostring(v))
  end
  local body = {}
  local result, code, headers, status = http.request({
    url = url,
    source = ltn12.source.string(json.encode(data)),
    sink = ltn12.sink.table(body),
    create = create,
    method = 'PUT',
    headers = {
      ['content-type'] = 'application/x-www-form-urlencoded',
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

function o.http.delete(url)
  local body = {}
  local result, code, headers, status = http.request({
    url = url,
    sink = ltn12.sink.table(body),
    method = 'DELETE',
    create = create,
    headers = {
      ['accept'] = 'application/json',
    },
    redirect = true,
  })
  if not tonumber(code) then
    error('Failed to DELETE '..url..'. Reason: '..code)
  end
  local data
  if #body > 0 then
    print(table.concat(body))
    data = json.decode(table.concat(body))
  end

  return code, data
end

return o
