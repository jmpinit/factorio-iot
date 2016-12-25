--[[
function onBuiltEntity(event)
  local entity = event.created_entity

  if entity.name == "iot-gateway" then
    game.print("see gateway created")
    global.gateways[entity.unit_number] = entity.get_or_create_control_behavior()
    game.print("control taken")
  end
end

script.on_event(defines.events.on_built_entity, function(event)
  onBuiltEntity(event)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  onBuiltEntity(event)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  player.print("i see you!")
  global.gateways = {}
  local itemStack = {name="iot-gateway", count=64}
  player.insert(itemStack)
end)

remote.add_interface("iot", {
  getGateways = function()
    return remote.call("debug", "sendGateways", global.gateways)
  end,
  setGatewayOutput(gatewayID, signalName)
    local gateway = 
  end,
  printSignals = function()
    for unit_number, gateway in pairs(global.gateways) do
      local parameters = gateway.parameters.parameters

      if parameters then
        --for i, param in pairs(parameters) do
          --game.print("parameters i: "..i)
          for i, signal in pairs(parameters) do
            game.print("param i: "..i)
            -- signal is parameter
            if signal.signal.name then
              game.print("name: "..signal.signal.name)
              game.print("type: "..signal.signal.type)
              game.print("count: "..signal.count)

              local circuitNet = gateway.get_circuit_network(defines.wire_type.red)

              if circuitNet then
                game.print("value: "..circuitNet.get_signal(signal.signal))
              end
            else
              game.print("no name")
            end
          end
          -- game.print(signal.type..", "..signal.name.." = "..signal.count)
        -- end
      else
        game.print("no signals")
      end
    end
  end,
  sayHello = function(target)
    game.print("hello "..target.."!")
  end
})
--]]