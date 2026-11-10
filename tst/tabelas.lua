local pico = dofile("../src/pico.lua")
pico.init(true)

pico.set.color_draw{ r = 255, g = 0, b = 0, a = 255 }
pico.output.draw_rect{ x = 10, y = 10, w = 20, h = 15 }

pico.init(false)
