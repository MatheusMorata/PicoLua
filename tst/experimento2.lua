local pico = dofile("../src/pico.lua")

pico.init(true)

pico.set.size(
    { x = 800, y = 600 },
    { x = 80,  y = 60 }
)

pico.set.color_draw({
    r = 0,
    g = 255,
    b = 0,
    a = 255
})

pico.set.anchor_draw({
    x = PICO_LEFT,
    y = PICO_TOP
})

local canto = pico.pos({
    x = 0,
    y = 0
})

pico.output.draw_rect({
    x = canto.x,
    y = canto.y,
    w = 10,
    h = 5
})

pico.set.anchor_draw({
    x = PICO_CENTER,
    y = PICO_MIDDLE
})

local centro = pico.pos({
    x = 50,
    y = 50
})

pico.output.draw_rect({
    x = centro.x,
    y = centro.y,
    w = 4,
    h = 4
})

while true do
    pico.input.delay(16)
end