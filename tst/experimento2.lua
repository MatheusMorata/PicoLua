local pico = dofile("../src/pico.lua")
pico.init(true)

pico.set.size({x = 800, y = 600}, {x = 80, y = 60})

local lx, ly = pico.pos({pico.POS_LEFT, pico.POS_TOP}, {2, 2})
local cx, cy = pico.pos({pico.POS_CENTER, pico.POS_MIDDLE})

pico.output.clear()
pico.set.color_draw({r = 0, g = 255, b = 0, a = 255})  
pico.set.style(pico.DRAW_FILL)

pico.output.draw_rect({x = lx, y = ly, w = 10, h = 5})
pico.output.draw_rect({x = cx, y = cy, w = 4, h = 4})

pico.input.delay(2000)
pico.init(false)