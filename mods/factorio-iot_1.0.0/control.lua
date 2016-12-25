local IotGateway = require('gateway')

function is_valid(entity)
  return (entity ~= nil and entity.valid)
end

function onBuiltEntity(event)
  local entity = event.created_entity

  if is_valid(event.created_entity) and event.created_entity.name == 'iot-gateway' then
    if global.gateways == nil then
      global.gateways = {}
    end

    local gateway = IotGateway:new(entity)
    global.gateways[entity.unit_number] = gateway
    gateway:connect('ws://localhost:8080')

    game.print('new gateway')
  end
end

function onTick(event)
  if event.tick % 120 == 5 then
    if global.gateways == nil then
      return
    end

    for unit_number, gateway in pairs(global.gateways) do
      if not is_valid(gateway.entity) or gateway.tick == nil then
        global.gateways[unit_number] = nil
      else
        gateway:tick()
      end
    end
  end
end

script.on_load(function()
  remote.add_interface('iot', {
    handleOpen= function(rpcId, connectionId)
      if global.rpcs then
        if global.rpcs[rpcId] ~= nil then
          game.print('handleOpen got: '..(connectionId or 'nil'))
          global.rpcs[rpcId](connectionId)
        else
          game.print('ignored opened event for connectionId: '..connectionId)
        end
      end
    end,
    handleMessage = function(connectionId, message)
      if global.rpcs then
        if global.rpcs[rpcId] ~= nil then
          global.rpcs[rpcId](connectionId, message)
        else
          game.print('ignored message event for connectionId: '..connectionId)
          game.print('ignored message: "'..message..'"')
        end
      end
    end,
    --[[
    printSignals = function()
      for unit_number, gateway in pairs(global.gateways) do
        local parameters = gateway.parameters.parameters

        if parameters then
          --for i, param in pairs(parameters) do
            --game.print('parameters i: '..i)
            for i, signal in pairs(parameters) do
              game.print('param i: '..i)
              -- signal is parameter
              if signal.signal.name then
                game.print('name: '..signal.signal.name)
                game.print('type: '..signal.signal.type)
                game.print('count: '..signal.count)

                local circuitNet = gateway.get_circuit_network(defines.wire_type.red)

                if circuitNet then
                  game.print('value: '..circuitNet.get_signal(signal.signal))
                end
              else
                game.print('no name')
              end
            end
            -- game.print(signal.type..', '..signal.name..' = '..signal.count)
          -- end
        else
          game.print('no signals')
        end
      end
    end,
    --]]
  })

  remote.call('websocket', 'setup', {
    interface= 'iot',
    on_open= 'handleOpen',
    on_message= 'handleMessage',
  })
end)

script.on_init(function()
  if global.gateways ~= nil then
    for i in global.gateways do
      global.gateways[i] = nil
    end
  end
end)

script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_built_entity, onBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, onBuiltEntity)
