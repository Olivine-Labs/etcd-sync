local json = require 'cjson'
local util = require 'etcd-sync.util'
local server = require 'etcd-sync.server'
local spy = require 'luassert.spy'

local raw = [[
{"action":"get","node":{"key":"/vulcand","dir":true,"nodes":[{"key":"/vulcand/listeners","dir":true,"nodes":[{"key":"/vulcand/listeners/https","value":"{\"Protocol\":\"https\", \"Address\":{\"Network\":\"tcp\", \"Address\":\"0.0.0.0:443\"}}","modifiedIndex":20263,"createdIndex":20263},{"key":"/vulcand/listeners/http","value":"{\"Protocol\":\"http\", \"Address\":{\"Network\":\"tcp\", \"Address\":\"0.0.0.0:80\"}}","modifiedIndex":20264,"createdIndex":20264}],"modifiedIndex":77,"createdIndex":77},{"key":"/vulcand/backends","dir":true,"nodes":[{"key":"/vulcand/backends/www","dir":true,"nodes":[{"key":"/vulcand/backends/www/backend","value":"{\"Type\": \"http\"}","modifiedIndex":20265,"createdIndex":20265},{"key":"/vulcand/backends/www/servers","dir":true,"nodes":[{"key":"/vulcand/backends/www/servers/srv1","value":"{\"URL\": \"http://10.200.0.220\"}","modifiedIndex":20266,"createdIndex":20266}],"modifiedIndex":11543,"createdIndex":11543}],"modifiedIndex":11542,"createdIndex":11542},{"key":"/vulcand/backends/www-io","dir":true,"nodes":[{"key":"/vulcand/backends/www-io/backend","value":"{\"Type\": \"http\"}","modifiedIndex":20267,"createdIndex":20267},{"key":"/vulcand/backends/www-io/servers","dir":true,"nodes":[{"key":"/vulcand/backends/www-io/servers/srv1","value":"{\"URL\": \"http://10.200.0.221\"}","modifiedIndex":20268,"createdIndex":20268}],"modifiedIndex":12935,"createdIndex":12935}],"modifiedIndex":12934,"createdIndex":12934},{"key":"/vulcand/backends/neflaria.default","dir":true,"nodes":[{"key":"/vulcand/backends/neflaria.default/backend","value":"{\"Type\": \"http\"}","modifiedIndex":20269,"createdIndex":20269},{"key":"/vulcand/backends/neflaria.default/servers","dir":true,"nodes":[{"key":"/vulcand/backends/neflaria.default/servers/srv1","value":"{\"URL\": \"http://10.200.0.200\"}","modifiedIndex":20270,"createdIndex":20270}],"modifiedIndex":257,"createdIndex":257}],"modifiedIndex":256,"createdIndex":256},{"key":"/vulcand/backends/jenkins","dir":true,"nodes":[{"key":"/vulcand/backends/jenkins/servers","dir":true,"nodes":[{"key":"/vulcand/backends/jenkins/servers/srv1","value":"{\"URL\": \"http://10.200.0.20\"}","modifiedIndex":20271,"createdIndex":20271}],"modifiedIndex":258,"createdIndex":258},{"key":"/vulcand/backends/jenkins/backend","value":"{\"Type\": \"http\"}","modifiedIndex":20272,"createdIndex":20272}],"modifiedIndex":258,"createdIndex":258}],"modifiedIndex":256,"createdIndex":256},{"key":"/vulcand/frontends","dir":true,"nodes":[{"key":"/vulcand/frontends/build.exoplay.net","dir":true,"nodes":[{"key":"/vulcand/frontends/build.exoplay.net/frontend","value":"{\"Type\": \"http\", \"BackendId\": \"jenkins\", \"Route\": \"Host(`build.exoplay.net`)\"}","modifiedIndex":20273,"createdIndex":20273}],"modifiedIndex":260,"createdIndex":260},{"key":"/vulcand/frontends/neflaria.http.default","dir":true,"nodes":[{"key":"/vulcand/frontends/neflaria.http.default/frontend","value":"{\"Type\": \"http\", \"BackendId\": \"neflaria.default\", \"Route\": \"Host(`neflaria.exoplay.net`)\"}","modifiedIndex":20274,"createdIndex":20274}],"modifiedIndex":261,"createdIndex":261},{"key":"/vulcand/frontends/neflaria.http.neflaria.com","dir":true,"nodes":[{"key":"/vulcand/frontends/neflaria.http.neflaria.com/frontend","value":"{\"Type\": \"http\", \"BackendId\": \"neflaria.default\", \"Route\": \"Host(`neflaria.com`)\"}","modifiedIndex":20275,"createdIndex":20275}],"modifiedIndex":262,"createdIndex":262},{"key":"/vulcand/frontends/www.exoplay.net","dir":true,"nodes":[{"key":"/vulcand/frontends/www.exoplay.net/frontend","value":"{\"Type\": \"http\", \"BackendId\": \"www\", \"Route\": \"Host(`www.exoplay.net`)\"}","modifiedIndex":20276,"createdIndex":20276}],"modifiedIndex":11544,"createdIndex":11544},{"key":"/vulcand/frontends/www.exoplay.io","dir":true,"nodes":[{"key":"/vulcand/frontends/www.exoplay.io/frontend","value":"{\"Type\": \"http\", \"BackendId\": \"www-io\", \"Route\": \"Host(`www.exoplay.io`)\"}","modifiedIndex":20277,"createdIndex":20277}],"modifiedIndex":12937,"createdIndex":12937}],"modifiedIndex":260,"createdIndex":260}],"modifiedIndex":77,"createdIndex":77}}
]]

local decoded = json.decode(raw)
local mockHttp = {}

function mockHttp.get(url)
  return 200, decoded
end

function mockHttp.put(url, data)
  return 200, nil
end

function mockHttp.delete(url)
  return 200, nil
end


describe('can process etcd output', function()
  it('can flatten an etcd dump json file', function()
    local data, index = util.flatten(decoded.action, decoded.node)
    assert.equal(20277, index)
    assert.equal(15, #data)
    assert.truthy(data[1].key)
    assert.truthy(data[1].value)
    flattened = data
  end)

  it('can process data end to end', function()

    spy.on(mockHttp, 'put')

    server.getUpdates(mockHttp, '', '', '')
    assert.spy(mockHttp.put).was_called(15)
  end)
end)
