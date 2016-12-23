remote.add_interface("iot", {
  sayHello = function(target)
    game.print("hello "..target.."!")
  end
})
