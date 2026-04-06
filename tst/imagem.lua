local pico = dofile("../src/pico.lua")

pico.init(true)
pico.set.size({x = 0, y = 0}, {x = 0, y = 0})
pico.output.draw_image({x = 250,y = 250}, "tux.png")
pico.input.delay(5000)
pico.init(false)