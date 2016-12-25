local EventEmitter = require('event_emitter')

local WebSocketInterface = EventEmitter:new()

function WebSocketInterface:send(data)
  self:emit('_send', data)
end

function WebSocketInterface:_rx(message)
  self:emit('message', message)
end

return WebSocketInterface
