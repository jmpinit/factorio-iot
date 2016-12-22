data:extend({
-- Item
  {
    type = "item",
    name = "iot-gateway",
    icon = "__factorio-iot__/graphics/icon/icon_iot-gateway.png",
    flags = {"goes-to-quickbar"},
    subgroup = "energy",
    order = "c[light]-a[iot-gateway]",
    place_result = "iot-gateway",
    stack_size = 50
  },

--Recipe
  {
    type = "recipe",
    name = "iot-gateway",
    enabled = "false",
    ingredients =
    {
      {"electronic-circuit", 5},
      {"iron-plate", 5},
      {"steel-plate", 2},
    },
    result = "iot-gateway"
  },

--Entity
  {
    type = "lamp",
    name = "iot-gateway",
    icon = "__factorio-iot__/graphics/icon/icon_iot-gateway.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.1, mining_time = 0.1, result = "iot-gateway"},
    max_health = 55,
    corpse = "small-remnants",
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage_per_tick = "1KW",
    picture_off =
    {
      filename = "__factorio-iot__/graphics/icon/icon_iot-gateway_onoff.png",
      priority = "high",
      width = 83,
      height = 75,
      shift = {0, -0.1}
    },
    picture_on =
    {
      filename = "__factorio-iot__/graphics/icon/icon_iot-gateway_onoff.png",
      priority = "high",
      width = 83,
      height = 75,
      x = 83,
      shift = {0, -0.1}
    }
  },
})
