local pico = dofile("../src/pico.lua")

pico.init(true)

pico.set.color_draw({
    r = 0,
    g = 255,
    b = 0,
    a = 255
})

pico.output.draw_rect({
    x = 27,
    y = 19,
    w = 10,
    h = 10
})

while true do
    pico.input.delay(16)
end