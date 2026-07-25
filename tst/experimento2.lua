local pico = dofile("../src/pico.lua")
pico.init(true)

pico.set.size({x = 800, y = 600}, {x = 80, y = 60})

pico.input.delay(5000)
pico.init(false)