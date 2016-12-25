local IotGateway = {}

-- function which returns a different, unique ID every time it is called
local uuid = (function()
  local id = 0

  return function()
    local uniqueId = id
    id = id + 1
    return tostring(uniqueId)
  end
end)()

function rpc(interface, fn, args, callback)
  if global.rpcs == nil then
    global.rpcs = {}
  end

  local rpcId = uuid()
  global.rpcs[rpcId] = function(connectionId)
    global.rpcs[rpcId] = nil
    callback(connectionId)
  end

  remote.call(interface, fn, rpcId, unpack(args))
end

function IotGateway:new(entity)
  self.__index = self

  local instance = {
    entity= entity,
    signalsLastTick= {},
    id= uuid()
  }

  setmetatable(instance, self)

  return instance
end

function IotGateway:sendChange(name, value)
  -- only send if we have a connection
  if not self:connected() then
    return
  end

  local msg = 'change,'..name..','..value
  game.print(msg) -- FIXME
  remote.call('websocket', 'tx', self.connectionId, msg)
end

function IotGateway:connect(address)
  -- only connect if not already connected
  if self:connected() then
    return
  end

  game.print('gateway connecting...')

  local gateway = self
  rpc('websocket', 'open', { address }, function (connectionId)
    game.print('gateway connected to the network')
    game.print('connection ID is '..(connectionId or 'nil'))
    gateway.connectionId = connectionId
  end)
end

function IotGateway:connected()
  return self.connectionId ~= nil
end

function IotGateway:tick()
  local behavior = self.entity.get_or_create_control_behavior()
  -- TODO also do green
  local circuit = behavior.get_circuit_network(defines.wire_type.red)

  if circuit == nil then
    -- no signals to check for changes
    return
  end

  -- create lookup for whether a signal with a given name is a combinator parameter
  local isParameter = {}
  for i, signal in ipairs(behavior.parameters.parameters) do
    if signal.signal ~= nil then
      if signal.signal.name then
        isParameter[signal.signal.name] = true
      end
    end
  end
  
  local changes = {}
  for i, signal in ipairs(circuit.signals) do
    local name = signal.signal.name -- SignalID has type and name

    if isParameter[name] then
      local value = signal.count
      local lastValue = self.signalsLastTick[name]

      game.print(name..' has value '..value..' and was '..(lastValue or 'nil'))

      if value ~= lastValue then
        changes[name] = value
        -- save value for checking against next tick
        self.signalsLastTick[name] = value
      end
    end
  end

  if not self:connected() then
    game.print('not connected, not sending')
    -- when not connected only keep track of changes
    return
  end

  -- send the changes to the internet
  for name, value in pairs(changes) do
    self:sendChange(name, value)
  end
end

return IotGateway
