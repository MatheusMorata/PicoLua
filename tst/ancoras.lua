local pico = dofile("../src/pico.lua")

pico.init(true)

pico.set.anchor_draw{x = 'LEFT', y = 'TOP'}

pico.set.color_draw{r = 255, g = 0, b = 0, a = 255}
pico.output.draw_rect{x = 32, y = 24, w = 20, h = 10}

pico.input.delay(3000)
pico.init(false)
