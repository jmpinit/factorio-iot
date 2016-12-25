local WebSocketInterface = require('websocket_interface')

-- function which returns a different, unique ID every time it is called
local uuid = (function()
  local id = 0

  return function()
    local uniqueId = id
    id = id + 1
    return tostring(uniqueId)
  end
end)()

function create(address, interfaceName, functionName)
  local ws = WebSocketInterface:new()
  local connectionId = uuid()

  -- everything sent via the remote interfaces must be serializable, so we cannot directly return
  -- the WebSocketInterface instance and must call a given callback interface with the data instead
  ws:on('message', function(message)
    remote.call(interfaceName, functionName, message)
  end)

  ws:on('_send', function (data)
    game.write_file('tx/'..connectionId..'.pipe', data, true, 0)
  end)

  if global.websockets == nil then
    global.websockets = {}
  end

  global.websockets[connectionId] = ws

  -- ask the helper program to create the WebSocket
  game.write_file('command.pipe', 'open,'..connectionId..','..address..'\n', true, 0)

  game.print('created socket with id '..connectionId..' and address '..address..' -> '..interfaceName..'.'..functionName)

  return connectionId
end

function tx(connectionId, data)
  if global.websockets[connectionId] == nil then
    game.print('tx for invalid connection ID: '..connectionId)
    return
  end

  game.print('tx['..connectionId..']: '..data)

  local ws = global.websockets[connectionId]
  ws:send(data)
end

function rx(connectionId, data)
  if global.websockets[connectionId] == nil then
    game.print('rx for invalid connection ID: '..connectionId)
    return
  end

  game.print('rx['..connectionId..']: '..data)

  local ws = global.websockets[connectionId]
  ws:_rx(data)
end

remote.add_interface('websocket', {
  create = create,
  tx = tx,
  -- called via RCON by the external helper program which has the actual WebSocket connection
  _rx = rx,
})
