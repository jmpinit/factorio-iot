data:extend({
  {
    type = "technology",
    name = "iot",
    icon = "__base__/graphics/technology/logistics.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "iot-gateway"
      }
    },
    prerequisites = {"logistics"},
    unit =
    {
      count = 50,
      ingredients = {{"science-pack-1", 1}},
      time = 15
    },
    order = "a-h-a",
  },
})
