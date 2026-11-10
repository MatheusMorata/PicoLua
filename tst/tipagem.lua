local pico = dofile("../src/pico.lua")
pico.init(true)

local cor = { r = 255, g = 0, b = 0, a = 255 }
pico.set.color_draw(cor)
pico.output.draw_rect{ x = 10, y = 10, w = 20, h = 15 }

pico.input.delay(1000)

cor = { r = 0, g = 255, b = 0, a = 255 }
pico.set.color_draw(cor)
pico.output.draw_rect{ x = 35, y = 10, w = 20, h = 15 }

pico.input.delay(1000)
pico.init(false)
